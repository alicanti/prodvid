import * as functions from 'firebase-functions';
import { defineSecret } from 'firebase-functions/params';
import { WiroClient } from './client';
import { WiroModelType, WIRO_MODEL_ENDPOINTS } from './types';

// Define secrets for Wiro API credentials
const wiroApiKey = defineSecret('WIRO_API_KEY');
const wiroApiSecret = defineSecret('WIRO_API_SECRET');

/**
 * Create a Wiro client with credentials from Secret Manager
 */
function createWiroClient(): WiroClient {
  const apiKey = wiroApiKey.value();
  const apiSecret = wiroApiSecret.value();

  if (!apiKey || !apiSecret) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Wiro API credentials not configured'
    );
  }

  return new WiroClient(apiKey, apiSecret);
}

/**
 * Validate model type
 */
function validateModelType(modelType: string): WiroModelType {
  if (!Object.keys(WIRO_MODEL_ENDPOINTS).includes(modelType)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Invalid modelType: ${modelType}. Valid types: ${Object.keys(WIRO_MODEL_ENDPOINTS).join(', ')}`
    );
  }
  return modelType as WiroModelType;
}

/**
 * Run a Wiro video generation task
 * Supports all 4 model types:
 * - wiro/3d-text-animations (caption only)
 * - wiro/product-ads (image only)
 * - wiro/product-ads-with-caption (image + caption)
 * - wiro/product-ads-with-logo (image + logo)
 */
export const runWiroTask = functions
  .runWith({
    secrets: [wiroApiKey, wiroApiSecret],
    timeoutSeconds: 60,
    memory: '256MB',
  })
  .https.onCall(async (data, context) => {
    // Require authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const { modelType, effectType, videoMode, inputImage, logoImage, caption } = data;

    // Validate model type
    const validatedModelType = validateModelType(modelType);

    // Validate effect type is provided
    if (!effectType) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'effectType is required'
      );
    }

    // Validate inputs based on model type
    switch (validatedModelType) {
      case 'wiro/3d-text-animations':
        if (!caption) {
          throw new functions.https.HttpsError(
            'invalid-argument',
            'caption is required for 3D Text Animations'
          );
        }
        break;

      case 'wiro/product-ads':
        if (!inputImage) {
          throw new functions.https.HttpsError(
            'invalid-argument',
            'inputImage is required for Product Ads'
          );
        }
        break;

      case 'wiro/product-ads-with-caption':
        if (!inputImage || !caption) {
          throw new functions.https.HttpsError(
            'invalid-argument',
            'inputImage and caption are required for Product Ads with Caption'
          );
        }
        break;

      case 'wiro/product-ads-with-logo':
        if (!inputImage || !logoImage) {
          throw new functions.https.HttpsError(
            'invalid-argument',
            'inputImage and logoImage are required for Product Ads with Logo'
          );
        }
        break;
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
      let response;

      switch (validatedModelType) {
        case 'wiro/3d-text-animations':
          response = await client.runTextAnimations(
            caption,
            effectType,
            videoMode || 'std'
          );
          break;

        case 'wiro/product-ads':
          response = await client.runProductAds(
            inputImage,
            effectType,
            videoMode || 'std'
          );
          break;

        case 'wiro/product-ads-with-caption':
          response = await client.runProductAdsWithCaption(
            inputImage,
            caption,
            effectType,
            videoMode || 'std'
          );
          break;

        case 'wiro/product-ads-with-logo':
          response = await client.runProductAdsWithLogo(
            inputImage,
            logoImage,
            effectType,
            videoMode || 'std'
          );
          break;
      }

      if (!response.result) {
        throw new functions.https.HttpsError(
          'internal',
          response.errors.join(', ') || 'Failed to start task'
        );
      }

      // TODO: Deduct credits from user
      // await deductCredits(userId, calculateCredits(videoMode, effectType));

      // TODO: Create task record in Firestore
      // await admin.firestore().collection('tasks').doc(response.taskid).set({
      //   userId: context.auth.uid,
      //   modelType: validatedModelType,
      //   effectType,
      //   videoMode,
      //   status: 'pending',
      //   createdAt: admin.firestore.FieldValue.serverTimestamp(),
      // });

      return {
        taskId: response.taskid,
        socketAccessToken: response.socketaccesstoken,
        result: response.result,
      };
    } catch (error) {
      console.error('Wiro runTask error:', error);
      throw new functions.https.HttpsError(
        'internal',
        error instanceof Error ? error.message : 'Unknown error'
      );
    }
  });

/**
 * Get Wiro task detail
 */
export const getWiroTaskDetail = functions
  .runWith({
    secrets: [wiroApiKey, wiroApiSecret],
    timeoutSeconds: 30,
    memory: '256MB',
  })
  .https.onCall(async (data, context) => {
    // Require authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const { taskId, socketToken } = data;

    if (!taskId && !socketToken) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Either taskId or socketToken is required'
      );
    }

    try {
      const client = createWiroClient();

      const response = taskId
        ? await client.getTaskDetailById(taskId)
        : await client.getTaskDetailByToken(socketToken);

      if (!response.result) {
        throw new functions.https.HttpsError(
          'internal',
          response.errors.join(', ') || 'Failed to get task detail'
        );
      }

      const task = response.tasklist[0];

      return {
        id: task?.id,
        uuid: task?.uuid,
        status: task?.status,
        elapsedSeconds: task?.elapsedseconds,
        outputs: task?.outputs.map((output) => ({
          id: output.id,
          name: output.name,
          contentType: output.contenttype,
          url: output.url,
          size: output.size,
        })),
      };
    } catch (error) {
      console.error('Wiro getTaskDetail error:', error);
      throw new functions.https.HttpsError(
        'internal',
        error instanceof Error ? error.message : 'Unknown error'
      );
    }
  });

/**
 * Kill a running Wiro task
 */
export const killWiroTask = functions
  .runWith({
    secrets: [wiroApiKey, wiroApiSecret],
    timeoutSeconds: 30,
    memory: '256MB',
  })
  .https.onCall(async (data, context) => {
    // Require authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const { taskId, socketToken } = data;

    if (!taskId && !socketToken) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Either taskId or socketToken is required'
      );
    }

    try {
      const client = createWiroClient();
      await client.killTask(taskId, socketToken);

      return { success: true };
    } catch (error) {
      console.error('Wiro killTask error:', error);
      throw new functions.https.HttpsError(
        'internal',
        error instanceof Error ? error.message : 'Unknown error'
      );
    }
  });

/**
 * Cancel a queued Wiro task
 */
export const cancelWiroTask = functions
  .runWith({
    secrets: [wiroApiKey, wiroApiSecret],
    timeoutSeconds: 30,
    memory: '256MB',
  })
  .https.onCall(async (data, context) => {
    // Require authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const { taskId } = data;

    if (!taskId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'taskId is required'
      );
    }

    try {
      const client = createWiroClient();
      await client.cancelTask(taskId);

      return { success: true };
    } catch (error) {
      console.error('Wiro cancelTask error:', error);
      throw new functions.https.HttpsError(
        'internal',
        error instanceof Error ? error.message : 'Unknown error'
      );
    }
  });

/**
 * Webhook callback for Wiro task completion (optional)
 */
export const wiroCallback = functions.https.onRequest(async (req, res) => {
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
  } catch (error) {
    console.error('Wiro callback error:', error);
    res.status(500).send('Internal error');
  }
});
