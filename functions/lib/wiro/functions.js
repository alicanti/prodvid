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
exports.wiroCallback = exports.cancelWiroTask = exports.killWiroTask = exports.getWiroTaskDetail = exports.runWiroTask = void 0;
const functions = __importStar(require("firebase-functions"));
const params_1 = require("firebase-functions/params");
const client_1 = require("./client");
// Define secrets for Wiro API credentials
const wiroApiKey = (0, params_1.defineSecret)('WIRO_API_KEY');
const wiroApiSecret = (0, params_1.defineSecret)('WIRO_API_SECRET');
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
 * Run a Wiro video generation task
 */
exports.runWiroTask = functions
    .runWith({
    secrets: [wiroApiKey, wiroApiSecret],
    timeoutSeconds: 60,
    memory: '256MB',
})
    .https.onCall(async (data, context) => {
    // Require authentication
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    // Validate input
    const { inputImage, effectType, videoMode } = data;
    if (!inputImage || !effectType) {
        throw new functions.https.HttpsError('invalid-argument', 'inputImage and effectType are required');
    }
    // TODO: Check user credits before proceeding
    // const userId = context.auth.uid;
    // const hasCredits = await checkUserCredits(userId);
    // if (!hasCredits) {
    //   throw new functions.https.HttpsError(
    //     'resource-exhausted',
    //     'Insufficient credits'
    //   );
    // }
    try {
        const client = createWiroClient();
        const response = await client.runTask({
            inputImage,
            effectType,
            videoMode: videoMode || 'std',
            // Optional: Set callback URL for webhook notifications
            // callbackUrl: `https://your-region-your-project.cloudfunctions.net/wiroCallback`,
        });
        if (!response.result) {
            throw new functions.https.HttpsError('internal', response.errors.join(', ') || 'Failed to start task');
        }
        // TODO: Deduct credits from user
        // await deductCredits(userId, calculateCredits(videoMode, effectType));
        return {
            taskId: response.taskid,
            socketAccessToken: response.socketaccesstoken,
            result: response.result,
        };
    }
    catch (error) {
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
        return {
            id: task === null || task === void 0 ? void 0 : task.id,
            uuid: task === null || task === void 0 ? void 0 : task.uuid,
            status: task === null || task === void 0 ? void 0 : task.status,
            elapsedSeconds: task === null || task === void 0 ? void 0 : task.elapsedseconds,
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
    const { taskId } = data;
    if (!taskId) {
        throw new functions.https.HttpsError('invalid-argument', 'taskId is required');
    }
    try {
        const client = createWiroClient();
        await client.cancelTask(taskId);
        return { success: true };
    }
    catch (error) {
        console.error('Wiro cancelTask error:', error);
        throw new functions.https.HttpsError('internal', error instanceof Error ? error.message : 'Unknown error');
    }
});
/**
 * Webhook callback for Wiro task completion (optional)
 */
exports.wiroCallback = functions.https.onRequest(async (req, res) => {
    if (req.method !== 'POST') {
        res.status(405).send('Method not allowed');
        return;
    }
    try {
        const taskData = req.body;
        console.log('Wiro callback received:', JSON.stringify(taskData));
        // TODO: Process callback
        // 1. Find the associated video project in Firestore
        // 2. Update the project status
        // 3. Save the output video URL
        // 4. Send push notification to user
        res.status(200).send('OK');
    }
    catch (error) {
        console.error('Wiro callback error:', error);
        res.status(500).send('Internal error');
    }
});
//# sourceMappingURL=functions.js.map