"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.refundTaskCredits = exports.updateTaskStatus2 = exports.updateTaskWithWiroId = exports.prepareGeneration = exports.wiroCallback = exports.getUserCredits = exports.cancelWiroTask = exports.killWiroTask = exports.getWiroTaskDetail = exports.runWiroTask = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const params_1 = require("firebase-functions/params");
const client_1 = require("./client");
const types_1 = require("./types");
// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
    admin.initializeApp();
}
const db = admin.firestore();
// Define secrets for Wiro API credentials
const wiroApiKey = (0, params_1.defineSecret)('WIRO_API_KEY');
const wiroApiSecret = (0, params_1.defineSecret)('WIRO_API_SECRET');
// Credit costs
const CREDITS = {
    STANDARD: 45,
    PRO: 80,
};
/**
 * Create a Wiro client with credentials from Secret Manager
 */
function createWiroClient() {
    const apiKey = wiroApiKey.value();
    const apiSecret = wiroApiSecret.value();
    if (!apiKey || !apiSecret) {
        throw new functions.https.HttpsError('failed-precondition', 'Wiro API credentials not configured');
    }
    return new client_1.WiroClient(apiKey, apiSecret);
}
/**
 * Validate model type
 */
function validateModelType(modelType) {
    if (!Object.keys(types_1.WIRO_MODEL_ENDPOINTS).includes(modelType)) {
        throw new functions.https.HttpsError('invalid-argument', `Invalid modelType: ${modelType}. Valid types: ${Object.keys(types_1.WIRO_MODEL_ENDPOINTS).join(', ')}`);
    }
    return modelType;
}
/**
 * Get credit cost based on video mode
 */
function getCreditCost(videoMode) {
    return videoMode === 'pro' ? CREDITS.PRO : CREDITS.STANDARD;
}
/**
 * Initial credits for new users
 */
const INITIAL_CREDITS = 100;
/**
 * Check and deduct user credits
 * Creates user with initial credits if not exists
 * Returns balance info, throws error if insufficient credits
 */
async function checkAndDeductCredits(userId, amount) {
    const userRef = db.collection('users').doc(userId);
    return db.runTransaction(async (transaction) => {
        var _a;
        const userDoc = await transaction.get(userRef);
        let currentCredits;
        if (!userDoc.exists) {
            // Create new user with initial credits
            currentCredits = INITIAL_CREDITS;
            transaction.set(userRef, {
                credits: currentCredits,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        else {
            const userData = userDoc.data();
            currentCredits = (_a = userData.credits) !== null && _a !== void 0 ? _a : 0;
        }
        if (currentCredits < amount) {
            throw new functions.https.HttpsError('resource-exhausted', `Insufficient credits. Need ${amount}, have ${currentCredits}`);
        }
        const newBalance = currentCredits - amount;
        transaction.update(userRef, {
            credits: newBalance,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return { newBalance, previousBalance: currentCredits };
    });
}
/**
 * Refund credits to user (in case of error)
 */
async function refundCredits(userId, amount) {
    const userRef = db.collection('users').doc(userId);
    await userRef.update({
        credits: admin.firestore.FieldValue.increment(amount),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
/**
 * Create task record in Firestore
 */
async function createTaskRecord(userId, taskId, socketToken, modelType, effectType, videoMode, creditCost) {
    await db.collection('tasks').doc(taskId).set({
        userId,
        taskId,
        socketToken,
        modelType,
        effectType,
        videoMode,
        creditCost,
        status: 'pending',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Also add to user's tasks subcollection for easy querying
    await db.collection('users').doc(userId).collection('tasks').doc(taskId).set({
        taskId,
        modelType,
        effectType,
        videoMode,
        status: 'pending',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
/**
 * Update task status in Firestore
 */
async function updateTaskStatus(taskId, status, outputs) {
    const updateData = {
        status,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    if (outputs) {
        updateData.outputs = outputs;
    }
    if (status === 'completed' || status === 'failed') {
        updateData.completedAt = admin.firestore.FieldValue.serverTimestamp();
    }
    await db.collection('tasks').doc(taskId).update(updateData);
}
/**
 * Run a Wiro video generation task
 * Supports all 4 model types with multipart image upload
 */
exports.runWiroTask = functions
    .runWith({
    secrets: [wiroApiKey, wiroApiSecret],
    timeoutSeconds: 120,
    memory: '512MB',
})
    .https.onCall(async (data, context) => {
    // Require authentication
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    const userId = context.auth.uid;
    const { modelType, effectType, videoMode = 'std', inputImage, logoImage, caption } = data;
    // Validate model type
    const validatedModelType = validateModelType(modelType);
    // Validate effect type is provided
    if (!effectType) {
        throw new functions.https.HttpsError('invalid-argument', 'effectType is required');
    }
    // Validate inputs based on model type
    switch (validatedModelType) {
        case 'wiro/3d-text-animations':
            if (!caption) {
                throw new functions.https.HttpsError('invalid-argument', 'caption is required for 3D Text Animations');
            }
            break;
        case 'wiro/product-ads':
            if (!inputImage) {
                throw new functions.https.HttpsError('invalid-argument', 'inputImage is required for Product Ads');
            }
            break;
        case 'wiro/product-ads-with-caption':
            if (!inputImage || !caption) {
                throw new functions.https.HttpsError('invalid-argument', 'inputImage and caption are required for Product Ads with Caption');
            }
            break;
        case 'wiro/product-ads-with-logo':
            if (!inputImage || !logoImage) {
                throw new functions.https.HttpsError('invalid-argument', 'inputImage and logoImage are required for Product Ads with Logo');
            }
            break;
    }
    // Calculate credit cost
    const creditCost = getCreditCost(videoMode);
    // Check and deduct credits
    let creditResult;
    try {
        creditResult = await checkAndDeductCredits(userId, creditCost);
        console.log(`Deducted ${creditCost} credits from user ${userId}. Balance: ${creditResult.previousBalance} -> ${creditResult.newBalance}`);
    }
    catch (error) {
        throw error; // Re-throw credit errors as-is
    }
    try {
        const client = createWiroClient();
        let response;
        switch (validatedModelType) {
            case 'wiro/3d-text-animations':
                response = await client.runTextAnimations(caption, effectType, videoMode);
                break;
            case 'wiro/product-ads':
                response = await client.runProductAds(inputImage, effectType, videoMode);
                break;
            case 'wiro/product-ads-with-caption':
                response = await client.runProductAdsWithCaption(inputImage, caption, effectType, videoMode);
                break;
            case 'wiro/product-ads-with-logo':
                response = await client.runProductAdsWithLogo(inputImage, logoImage, effectType, videoMode);
                break;
        }
        if (!response.result) {
            // Refund credits on Wiro API error
            await refundCredits(userId, creditCost);
            console.log(`Refunded ${creditCost} credits to user ${userId} due to Wiro API error`);
            throw new functions.https.HttpsError('internal', response.errors.join(', ') || 'Failed to start task');
        }
        // Create task record in Firestore
        await createTaskRecord(userId, response.taskid, response.socketaccesstoken, validatedModelType, effectType, videoMode, creditCost);
        return {
            success: true,
            taskId: response.taskid,
            socketToken: response.socketaccesstoken,
            creditsUsed: creditCost,
            creditsRemaining: creditResult.newBalance,
        };
    }
    catch (error) {
        // Refund credits on any error
        await refundCredits(userId, creditCost);
        console.log(`Refunded ${creditCost} credits to user ${userId} due to error: ${error}`);
        console.error('Wiro runTask error:', error);
        throw new functions.https.HttpsError('internal', error instanceof Error ? error.message : 'Unknown error');
    }
});
/**
 * Get Wiro task detail
 */
exports.getWiroTaskDetail = functions
    .runWith({
    secrets: [wiroApiKey, wiroApiSecret],
    timeoutSeconds: 30,
    memory: '256MB',
})
    .https.onCall(async (data, context) => {
    // Require authentication
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    const { taskId, socketToken } = data;
    if (!taskId && !socketToken) {
        throw new functions.https.HttpsError('invalid-argument', 'Either taskId or socketToken is required');
    }
    try {
        const client = createWiroClient();
        const response = taskId
            ? await client.getTaskDetailById(taskId)
            : await client.getTaskDetailByToken(socketToken);
        if (!response.result) {
            throw new functions.https.HttpsError('internal', response.errors.join(', ') || 'Failed to get task detail');
        }
        const task = response.tasklist[0];
        // Map status for Flutter
        let mappedStatus = 'pending';
        if ((task === null || task === void 0 ? void 0 : task.status) === 'task_postprocess_end') {
            mappedStatus = 'completed';
        }
        else if ((task === null || task === void 0 ? void 0 : task.status) === 'task_cancel') {
            mappedStatus = 'cancelled';
        }
        else if (task === null || task === void 0 ? void 0 : task.status.includes('task_')) {
            mappedStatus = 'processing';
        }
        // Update task status in Firestore if completed
        if (taskId && (mappedStatus === 'completed' || mappedStatus === 'cancelled')) {
            const outputs = task === null || task === void 0 ? void 0 : task.outputs.map((output) => ({
                url: output.url,
                name: output.name,
                contentType: output.contenttype,
                size: output.size,
            }));
            await updateTaskStatus(taskId, mappedStatus, outputs);
        }
        return {
            success: true,
            id: task === null || task === void 0 ? void 0 : task.id,
            uuid: task === null || task === void 0 ? void 0 : task.uuid,
            status: mappedStatus,
            rawStatus: task === null || task === void 0 ? void 0 : task.status,
            elapsedSeconds: parseInt((task === null || task === void 0 ? void 0 : task.elapsedseconds) || '0', 10),
            outputs: task === null || task === void 0 ? void 0 : task.outputs.map((output) => ({
                id: output.id,
                name: output.name,
                contentType: output.contenttype,
                url: output.url,
                size: output.size,
            })),
        };
    }
    catch (error) {
        console.error('Wiro getTaskDetail error:', error);
        throw new functions.https.HttpsError('internal', error instanceof Error ? error.message : 'Unknown error');
    }
});
/**
 * Kill a running Wiro task
 */
exports.killWiroTask = functions
    .runWith({
    secrets: [wiroApiKey, wiroApiSecret],
    timeoutSeconds: 30,
    memory: '256MB',
})
    .https.onCall(async (data, context) => {
    // Require authentication
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    const { taskId, socketToken } = data;
    if (!taskId && !socketToken) {
        throw new functions.https.HttpsError('invalid-argument', 'Either taskId or socketToken is required');
    }
    try {
        const client = createWiroClient();
        await client.killTask(taskId, socketToken);
        // Update task status in Firestore
        if (taskId) {
            await updateTaskStatus(taskId, 'killed');
        }
        return { success: true };
    }
    catch (error) {
        console.error('Wiro killTask error:', error);
        throw new functions.https.HttpsError('internal', error instanceof Error ? error.message : 'Unknown error');
    }
});
/**
 * Cancel a queued Wiro task
 */
exports.cancelWiroTask = functions
    .runWith({
    secrets: [wiroApiKey, wiroApiSecret],
    timeoutSeconds: 30,
    memory: '256MB',
})
    .https.onCall(async (data, context) => {
    // Require authentication
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    const userId = context.auth.uid;
    const { taskId } = data;
    if (!taskId) {
        throw new functions.https.HttpsError('invalid-argument', 'taskId is required');
    }
    try {
        // Get task from Firestore to verify ownership and get credit info
        const taskDoc = await db.collection('tasks').doc(taskId).get();
        if (!taskDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Task not found');
        }
        const taskData = taskDoc.data();
        if (taskData.userId !== userId) {
            throw new functions.https.HttpsError('permission-denied', 'Not authorized to cancel this task');
        }
        // Only refund if task is still pending
        if (taskData.status === 'pending') {
            await refundCredits(userId, taskData.creditCost);
            console.log(`Refunded ${taskData.creditCost} credits to user ${userId} for cancelled task ${taskId}`);
        }
        const client = createWiroClient();
        await client.cancelTask(taskId);
        // Update task status in Firestore
        await updateTaskStatus(taskId, 'cancelled');
        return { success: true };
    }
    catch (error) {
        console.error('Wiro cancelTask error:', error);
        throw new functions.https.HttpsError('internal', error instanceof Error ? error.message : 'Unknown error');
    }
});
/**
 * Get user's credit balance
 */
exports.getUserCredits = functions
    .https.onCall(async (data, context) => {
    var _a, _b;
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    const userId = context.auth.uid;
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
        // Create user document with initial credits if doesn't exist
        await db.collection('users').doc(userId).set({
            credits: 100, // Initial free credits
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return { credits: 100 };
    }
    return { credits: (_b = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.credits) !== null && _b !== void 0 ? _b : 0 };
});
/**
 * Webhook callback for Wiro task completion
 */
exports.wiroCallback = functions.https.onRequest(async (req, res) => {
    if (req.method !== 'POST') {
        res.status(405).send('Method not allowed');
        return;
    }
    try {
        const taskData = req.body;
        console.log('Wiro callback received:', JSON.stringify(taskData));
        const { taskid, status, outputs } = taskData;
        if (!taskid) {
            res.status(400).send('Missing taskid');
            return;
        }
        // Map status
        let mappedStatus = 'processing';
        if (status === 'task_postprocess_end') {
            mappedStatus = 'completed';
        }
        else if (status === 'task_cancel') {
            mappedStatus = 'cancelled';
        }
        // Update task in Firestore
        await updateTaskStatus(taskid, mappedStatus, outputs);
        // TODO: Send push notification to user
        // const taskDoc = await db.collection('tasks').doc(taskid).get();
        // if (taskDoc.exists) {
        //   const userId = taskDoc.data()?.userId;
        //   await sendPushNotification(userId, 'Video Ready!', 'Your video has been generated.');
        // }
        res.status(200).send('OK');
    }
    catch (error) {
        console.error('Wiro callback error:', error);
        res.status(500).send('Internal error');
    }
});
/**
 * Prepare video generation - check credits, deduct, create task record
 * Returns API credentials for Flutter to call Wiro directly
 */
exports.prepareGeneration = functions
    .runWith({
    secrets: [wiroApiKey, wiroApiSecret],
    timeoutSeconds: 30,
    memory: '256MB',
})
    .https.onCall(async (data, context) => {
    // Require authentication
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    const userId = context.auth.uid;
    const { modelType, effectType, videoMode = 'std' } = data;
    // Validate model type
    const validatedModelType = validateModelType(modelType);
    // Validate effect type is provided
    if (!effectType) {
        throw new functions.https.HttpsError('invalid-argument', 'effectType is required');
    }
    // Calculate credit cost
    const creditCost = getCreditCost(videoMode);
    // Check and deduct credits
    let creditResult;
    try {
        creditResult = await checkAndDeductCredits(userId, creditCost);
        console.log(`Deducted ${creditCost} credits from user ${userId}. Balance: ${creditResult.previousBalance} -> ${creditResult.newBalance}`);
    }
    catch (error) {
        throw error;
    }
    // Generate a temporary task ID for Firestore (will be updated with real one)
    const tempTaskId = `pending_${Date.now()}_${Math.random().toString(36).substring(7)}`;
    // Create pending task record in Firestore
    await db.collection('tasks').doc(tempTaskId).set({
        tempId: tempTaskId,
        userId,
        modelType: validatedModelType,
        effectType,
        videoMode,
        creditCost,
        status: 'preparing',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Return API credentials and task info
    return {
        success: true,
        tempTaskId,
        apiKey: wiroApiKey.value(),
        apiSecret: wiroApiSecret.value(),
        creditCost,
        creditsRemaining: creditResult.newBalance,
    };
});
/**
 * Update task with real Wiro task ID after generation starts
 */
exports.updateTaskWithWiroId = functions
    .runWith({
    timeoutSeconds: 30,
    memory: '256MB',
})
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    const userId = context.auth.uid;
    const { tempTaskId, wiroTaskId, socketToken } = data;
    if (!tempTaskId || !wiroTaskId) {
        throw new functions.https.HttpsError('invalid-argument', 'tempTaskId and wiroTaskId are required');
    }
    // Get the temp task
    const tempTaskRef = db.collection('tasks').doc(tempTaskId);
    const tempTaskDoc = await tempTaskRef.get();
    if (!tempTaskDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Task not found');
    }
    const taskData = tempTaskDoc.data();
    if ((taskData === null || taskData === void 0 ? void 0 : taskData.userId) !== userId) {
        throw new functions.https.HttpsError('permission-denied', 'Not authorized to update this task');
    }
    // Create new document with real Wiro task ID
    await db.collection('tasks').doc(wiroTaskId).set(Object.assign(Object.assign({}, taskData), { taskId: wiroTaskId, socketToken, status: 'processing', tempId: null, updatedAt: admin.firestore.FieldValue.serverTimestamp() }));
    // Delete temp task
    await tempTaskRef.delete();
    return { success: true, taskId: wiroTaskId };
});
/**
 * Update task status from Flutter polling
 */
exports.updateTaskStatus2 = functions
    .runWith({
    timeoutSeconds: 30,
    memory: '256MB',
})
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    const userId = context.auth.uid;
    const { taskId, status, outputs, videoUrl } = data;
    if (!taskId || !status) {
        throw new functions.https.HttpsError('invalid-argument', 'taskId and status are required');
    }
    // Get the task
    const taskRef = db.collection('tasks').doc(taskId);
    const taskDoc = await taskRef.get();
    if (!taskDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Task not found');
    }
    const taskData = taskDoc.data();
    if ((taskData === null || taskData === void 0 ? void 0 : taskData.userId) !== userId) {
        throw new functions.https.HttpsError('permission-denied', 'Not authorized to update this task');
    }
    // Update task
    const updateData = {
        status,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    if (outputs) {
        updateData.outputs = outputs;
    }
    if (videoUrl) {
        updateData.videoUrl = videoUrl;
    }
    if (status === 'completed' || status === 'failed' || status === 'cancelled') {
        updateData.completedAt = admin.firestore.FieldValue.serverTimestamp();
    }
    await taskRef.update(updateData);
    return { success: true };
});
/**
 * Refund credits when task fails or is cancelled
 */
exports.refundTaskCredits = functions
    .runWith({
    timeoutSeconds: 30,
    memory: '256MB',
})
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    const userId = context.auth.uid;
    const { taskId } = data;
    if (!taskId) {
        throw new functions.https.HttpsError('invalid-argument', 'taskId is required');
    }
    // Get the task
    const taskRef = db.collection('tasks').doc(taskId);
    const taskDoc = await taskRef.get();
    if (!taskDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Task not found');
    }
    const taskData = taskDoc.data();
    if ((taskData === null || taskData === void 0 ? void 0 : taskData.userId) !== userId) {
        throw new functions.https.HttpsError('permission-denied', 'Not authorized');
    }
    // Check if already refunded
    if (taskData === null || taskData === void 0 ? void 0 : taskData.refunded) {
        return { success: true, alreadyRefunded: true };
    }
    // Refund credits
    const creditCost = (taskData === null || taskData === void 0 ? void 0 : taskData.creditCost) || 0;
    if (creditCost > 0) {
        await refundCredits(userId, creditCost);
        await taskRef.update({
            refunded: true,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
    return { success: true, refundedCredits: creditCost };
});
//# sourceMappingURL=functions.js.map