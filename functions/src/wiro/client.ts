import * as crypto from 'crypto';
import fetch from 'node-fetch';
import {
  WiroModelType,
  WiroRunTaskRequest,
  WiroRunTaskResponse,
  WiroTaskDetailResponse,
  WIRO_MODEL_ENDPOINTS,
} from './types';

const WIRO_BASE_URL = 'https://api.wiro.ai/v1';
const TASK_DETAIL_ENDPOINT = `${WIRO_BASE_URL}/Task/Detail`;
const TASK_KILL_ENDPOINT = `${WIRO_BASE_URL}/Task/Kill`;
const TASK_CANCEL_ENDPOINT = `${WIRO_BASE_URL}/Task/Cancel`;

/**
 * Wiro API client
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
  private generateHeaders(): Record<string, string> {
    // Generate nonce (unix timestamp)
    const nonce = Math.floor(Date.now() / 1000).toString();

    // Generate HMAC-SHA256 signature
    // Formula: hmac-SHA256(API_SECRET + Nonce) with API_KEY as key
    const signatureData = this.apiSecret + nonce;
    const signature = crypto
      .createHmac('sha256', this.apiKey)
      .update(signatureData)
      .digest('hex');

    return {
      'Content-Type': 'application/json',
      'x-api-key': this.apiKey,
      'x-nonce': nonce,
      'x-signature': signature,
    };
  }

  /**
   * Run a new video generation task
   * @param modelType The Wiro model to use
   * @param request The task request parameters
   */
  async runTask(
    modelType: WiroModelType,
    request: WiroRunTaskRequest
  ): Promise<WiroRunTaskResponse> {
    const endpoint = WIRO_MODEL_ENDPOINTS[modelType];
    
    if (!endpoint) {
      throw new Error(`Unknown model type: ${modelType}`);
    }

    const response = await fetch(endpoint, {
      method: 'POST',
      headers: this.generateHeaders(),
      body: JSON.stringify(request),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
    }

    return (await response.json()) as WiroRunTaskResponse;
  }

  /**
   * Run 3D Text Animations task
   */
  async runTextAnimations(
    caption: string,
    effectType: string,
    videoMode: 'std' | 'pro' = 'std',
    callbackUrl?: string
  ): Promise<WiroRunTaskResponse> {
    return this.runTask('wiro/3d-text-animations', {
      caption,
      effectType,
      videoMode,
      callbackUrl,
    });
  }

  /**
   * Run Product Ads task
   */
  async runProductAds(
    inputImage: string,
    effectType: string,
    videoMode: 'std' | 'pro' = 'std',
    callbackUrl?: string
  ): Promise<WiroRunTaskResponse> {
    return this.runTask('wiro/product-ads', {
      inputImage,
      effectType,
      videoMode,
      callbackUrl,
    });
  }

  /**
   * Run Product Ads with Caption task
   */
  async runProductAdsWithCaption(
    inputImage: string,
    caption: string,
    effectType: string,
    videoMode: 'std' | 'pro' = 'std',
    callbackUrl?: string
  ): Promise<WiroRunTaskResponse> {
    return this.runTask('wiro/product-ads-with-caption', {
      inputImage,
      caption,
      effectType,
      videoMode,
      callbackUrl,
    });
  }

  /**
   * Run Product Ads with Logo task
   */
  async runProductAdsWithLogo(
    productImage: string,
    logoImage: string,
    effectType: string,
    videoMode: 'std' | 'pro' = 'std',
    callbackUrl?: string
  ): Promise<WiroRunTaskResponse> {
    return this.runTask('wiro/product-ads-with-logo', {
      inputImage: [productImage, logoImage],
      effectType,
      videoMode,
      callbackUrl,
    });
  }

  /**
   * Get task detail by task ID
   */
  async getTaskDetailById(taskId: string): Promise<WiroTaskDetailResponse> {
    const response = await fetch(TASK_DETAIL_ENDPOINT, {
      method: 'POST',
      headers: this.generateHeaders(),
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
      headers: this.generateHeaders(),
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
      headers: this.generateHeaders(),
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
      headers: this.generateHeaders(),
      body: JSON.stringify({ taskid: taskId }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Wiro API error: ${response.status} ${response.statusText} - ${errorText}`);
    }

    return (await response.json()) as WiroTaskDetailResponse;
  }
}
