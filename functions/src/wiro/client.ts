import * as crypto from 'crypto';
import fetch from 'node-fetch';
import FormData from 'form-data';
import {
  WiroModelType,
  WiroRunTaskResponse,
  WiroTaskDetailResponse,
  WIRO_MODEL_ENDPOINTS,
} from './types';

const WIRO_BASE_URL = 'https://api.wiro.ai/v1';
const TASK_DETAIL_ENDPOINT = `${WIRO_BASE_URL}/Task/Detail`;
const TASK_KILL_ENDPOINT = `${WIRO_BASE_URL}/Task/Kill`;
const TASK_CANCEL_ENDPOINT = `${WIRO_BASE_URL}/Task/Cancel`;

/**
 * Wiro API client with multipart support for image uploads
 */
export class WiroClient {
  private apiKey: string;
  private apiSecret: string;

  constructor(apiKey: string, apiSecret: string) {
    this.apiKey = apiKey;
    this.apiSecret = apiSecret;
  }

  /**
   * Generate authentication headers for Wiro API
   */
  private generateAuthHeaders(): Record<string, string> {
    const nonce = Math.floor(Date.now() / 1000).toString();
    const signatureData = this.apiSecret + nonce;
    const signature = crypto
      .createHmac('sha256', this.apiKey)
      .update(signatureData)
      .digest('hex');

    return {
      'x-api-key': this.apiKey,
      'x-nonce': nonce,
      'x-signature': signature,
    };
  }

  /**
   * Convert base64 image to Buffer
   */
  private base64ToBuffer(base64: string): Buffer {
    // Remove data URL prefix if present
    const base64Data = base64.replace(/^data:image\/\w+;base64,/, '');
    return Buffer.from(base64Data, 'base64');
  }

  /**
   * Run a task with multipart form-data (for image uploads)
   */
  private async runTaskMultipart(
    modelType: WiroModelType,
    formData: FormData
  ): Promise<WiroRunTaskResponse> {
    const endpoint = WIRO_MODEL_ENDPOINTS[modelType];
    
    if (!endpoint) {
      throw new Error(`Unknown model type: ${modelType}`);
    }

    const authHeaders = this.generateAuthHeaders();

    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        ...authHeaders,
        ...formData.getHeaders(),
      },
      body: formData,
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
    }

    return (await response.json()) as WiroRunTaskResponse;
  }

  /**
   * Run a task with JSON body (for text-only requests)
   */
  private async runTaskJson(
    modelType: WiroModelType,
    body: Record<string, unknown>
  ): Promise<WiroRunTaskResponse> {
    const endpoint = WIRO_MODEL_ENDPOINTS[modelType];
    
    if (!endpoint) {
      throw new Error(`Unknown model type: ${modelType}`);
    }

    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        ...this.generateAuthHeaders(),
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
    }

    return (await response.json()) as WiroRunTaskResponse;
  }

  /**
   * Run 3D Text Animations task (text only - uses JSON)
   */
  async runTextAnimations(
    caption: string,
    effectType: string,
    videoMode: 'std' | 'pro' = 'std',
    callbackUrl?: string
  ): Promise<WiroRunTaskResponse> {
    return this.runTaskJson('wiro/3d-text-animations', {
      caption,
      effectType,
      videoMode,
      ...(callbackUrl && { callbackUrl }),
    });
  }

  /**
   * Run Product Ads task (image only - uses multipart)
   * @param inputImageBase64 Base64 encoded image
   */
  async runProductAds(
    inputImageBase64: string,
    effectType: string,
    videoMode: 'std' | 'pro' = 'std',
    callbackUrl?: string
  ): Promise<WiroRunTaskResponse> {
    const formData = new FormData();
    formData.append('inputImage', this.base64ToBuffer(inputImageBase64), {
      filename: 'product.jpg',
      contentType: 'image/jpeg',
    });
    formData.append('effectType', effectType);
    formData.append('videoMode', videoMode);
    if (callbackUrl) {
      formData.append('callbackUrl', callbackUrl);
    }

    return this.runTaskMultipart('wiro/product-ads', formData);
  }

  /**
   * Run Product Ads with Caption task (image + text - uses multipart)
   */
  async runProductAdsWithCaption(
    inputImageBase64: string,
    caption: string,
    effectType: string,
    videoMode: 'std' | 'pro' = 'std',
    callbackUrl?: string
  ): Promise<WiroRunTaskResponse> {
    const formData = new FormData();
    formData.append('inputImage', this.base64ToBuffer(inputImageBase64), {
      filename: 'product.jpg',
      contentType: 'image/jpeg',
    });
    formData.append('caption', caption);
    formData.append('effectType', effectType);
    formData.append('videoMode', videoMode);
    if (callbackUrl) {
      formData.append('callbackUrl', callbackUrl);
    }

    return this.runTaskMultipart('wiro/product-ads-with-caption', formData);
  }

  /**
   * Run Product Ads with Logo task (two images - uses multipart)
   */
  async runProductAdsWithLogo(
    productImageBase64: string,
    logoImageBase64: string,
    effectType: string,
    videoMode: 'std' | 'pro' = 'std',
    callbackUrl?: string
  ): Promise<WiroRunTaskResponse> {
    const formData = new FormData();
    // Wiro expects inputImage array - we append both with same field name
    formData.append('inputImage', this.base64ToBuffer(productImageBase64), {
      filename: 'product.jpg',
      contentType: 'image/jpeg',
    });
    formData.append('inputImage', this.base64ToBuffer(logoImageBase64), {
      filename: 'logo.png',
      contentType: 'image/png',
    });
    formData.append('effectType', effectType);
    formData.append('videoMode', videoMode);
    if (callbackUrl) {
      formData.append('callbackUrl', callbackUrl);
    }

    return this.runTaskMultipart('wiro/product-ads-with-logo', formData);
  }

  /**
   * Get task detail by task ID
   */
  async getTaskDetailById(taskId: string): Promise<WiroTaskDetailResponse> {
    const response = await fetch(TASK_DETAIL_ENDPOINT, {
      method: 'POST',
      headers: {
        ...this.generateAuthHeaders(),
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ taskid: taskId }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
    }

    return (await response.json()) as WiroTaskDetailResponse;
  }

  /**
   * Get task detail by socket token
   */
  async getTaskDetailByToken(token: string): Promise<WiroTaskDetailResponse> {
    const response = await fetch(TASK_DETAIL_ENDPOINT, {
      method: 'POST',
      headers: {
        ...this.generateAuthHeaders(),
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ tasktoken: token }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
    }

    return (await response.json()) as WiroTaskDetailResponse;
  }

  /**
   * Kill a running task
   */
  async killTask(taskId?: string, socketToken?: string): Promise<WiroTaskDetailResponse> {
    const body = taskId
      ? { taskid: taskId }
      : { socketaccesstoken: socketToken };

    const response = await fetch(TASK_KILL_ENDPOINT, {
      method: 'POST',
      headers: {
        ...this.generateAuthHeaders(),
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
    }

    return (await response.json()) as WiroTaskDetailResponse;
  }

  /**
   * Cancel a queued task
   */
  async cancelTask(taskId: string): Promise<WiroTaskDetailResponse> {
    const response = await fetch(TASK_CANCEL_ENDPOINT, {
      method: 'POST',
      headers: {
        ...this.generateAuthHeaders(),
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ taskid: taskId }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
    }

    return (await response.json()) as WiroTaskDetailResponse;
  }
}
