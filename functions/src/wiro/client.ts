import * as crypto from 'crypto';
import fetch from 'node-fetch';
import {
  WiroRunTaskRequest,
  WiroRunTaskResponse,
  WiroTaskDetailResponse,
} from './types';

const WIRO_BASE_URL = 'https://api.wiro.ai/v1';
const RUN_ENDPOINT = `${WIRO_BASE_URL}/Run/wiro/product-ads`;
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
   */
  async runTask(request: WiroRunTaskRequest): Promise<WiroRunTaskResponse> {
    const response = await fetch(RUN_ENDPOINT, {
      method: 'POST',
      headers: this.generateHeaders(),
      body: JSON.stringify(request),
    });

    if (!response.ok) {
      throw new Error(`Wiro API error: ${response.status} ${response.statusText}`);
    }

    return (await response.json()) as WiroRunTaskResponse;
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
      throw new Error(`Wiro API error: ${response.status} ${response.statusText}`);
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
      throw new Error(`Wiro API error: ${response.status} ${response.statusText}`);
    }

    return (await response.json()) as WiroTaskDetailResponse;
  }

  /**
   * Kill a running task
   */
  async killTask(taskId?: string, socketToken?: string): Promise<void> {
    const body = taskId
      ? { taskid: taskId }
      : { socketaccesstoken: socketToken };

    const response = await fetch(TASK_KILL_ENDPOINT, {
      method: 'POST',
      headers: this.generateHeaders(),
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      throw new Error(`Wiro API error: ${response.status} ${response.statusText}`);
    }
  }

  /**
   * Cancel a queued task
   */
  async cancelTask(taskId: string): Promise<void> {
    const response = await fetch(TASK_CANCEL_ENDPOINT, {
      method: 'POST',
      headers: this.generateHeaders(),
      body: JSON.stringify({ taskid: taskId }),
    });

    if (!response.ok) {
      throw new Error(`Wiro API error: ${response.status} ${response.statusText}`);
    }
  }
}

