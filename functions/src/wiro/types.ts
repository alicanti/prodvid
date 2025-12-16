/**
 * Wiro API types
 */

// =============================================================================
// MODEL TYPES
// =============================================================================

export type WiroModelType =
  | 'wiro/3d-text-animations'
  | 'wiro/product-ads'
  | 'wiro/product-ads-with-caption'
  | 'wiro/product-ads-with-logo';

export const WIRO_MODEL_ENDPOINTS: Record<WiroModelType, string> = {
  'wiro/3d-text-animations': 'https://api.wiro.ai/v1/Run/wiro/3d-text-animations',
  'wiro/product-ads': 'https://api.wiro.ai/v1/Run/wiro/product-ads',
  'wiro/product-ads-with-caption': 'https://api.wiro.ai/v1/Run/wiro/product-ads-with-caption',
  'wiro/product-ads-with-logo': 'https://api.wiro.ai/v1/Run/wiro/product-ads-with-logo',
};

// =============================================================================
// REQUEST TYPES
// =============================================================================

/** Base request interface */
interface WiroBaseRequest {
  effectType: string;
  videoMode: 'std' | 'pro';
  callbackUrl?: string;
}

/** Request for 3D Text Animations (text only) */
export interface WiroTextAnimationsRequest extends WiroBaseRequest {
  caption: string;
}

/** Request for Product Ads (image only) */
export interface WiroProductAdsRequest extends WiroBaseRequest {
  inputImage: string;
}

/** Request for Product Ads with Caption (image + text) */
export interface WiroProductAdsCaptionRequest extends WiroBaseRequest {
  inputImage: string;
  caption: string;
}

/** Request for Product Ads with Logo (image + logo) */
export interface WiroProductAdsLogoRequest extends WiroBaseRequest {
  inputImage: string | string[];  // [productImage, logoImage]
}

/** Union type for all request types */
export type WiroRunTaskRequest =
  | WiroTextAnimationsRequest
  | WiroProductAdsRequest
  | WiroProductAdsCaptionRequest
  | WiroProductAdsLogoRequest;

// =============================================================================
// RESPONSE TYPES
// =============================================================================

export interface WiroRunTaskResponse {
  errors: string[];
  taskid: string;
  socketaccesstoken: string;
  result: boolean;
}

export interface WiroTaskOutput {
  id: string;
  name: string;
  contenttype: string;
  parentid: string;
  uuid: string;
  size: string;
  addedtime: string;
  modifiedtime: string;
  accesskey: string;
  url: string;
}

export interface WiroTaskDetail {
  id: string;
  uuid: string;
  socketaccesstoken: string;
  parameters: Record<string, unknown>;
  debugoutput: string;
  debugerror: string;
  starttime: string;
  endtime: string;
  elapsedseconds: string;
  status: WiroTaskStatus;
  createtime: string;
  canceltime: string;
  assigntime: string;
  accepttime: string;
  preprocessstarttime: string;
  preprocessendtime: string;
  postprocessstarttime: string;
  postprocessendtime: string;
  outputs: WiroTaskOutput[];
  size: string;
}

export interface WiroTaskDetailResponse {
  total: string;
  errors: string[];
  tasklist: WiroTaskDetail[];
  result: boolean;
}

// =============================================================================
// TASK STATUS
// =============================================================================

export type WiroTaskStatus =
  | 'task_queue'
  | 'task_accept'
  | 'task_assign'
  | 'task_preprocess_start'
  | 'task_preprocess_end'
  | 'task_start'
  | 'task_output'
  | 'task_postprocess_end'
  | 'task_cancel';

export const COMPLETED_STATUSES: WiroTaskStatus[] = [
  'task_postprocess_end',
  'task_cancel',
];

export const isTaskCompleted = (status: WiroTaskStatus): boolean => {
  return COMPLETED_STATUSES.includes(status);
};

export const isTaskSuccessful = (status: WiroTaskStatus): boolean => {
  return status === 'task_postprocess_end';
};

// =============================================================================
// CLOUD FUNCTION REQUEST TYPES
// =============================================================================

/** Request from Flutter app to Cloud Function */
export interface CloudFunctionRunTaskRequest {
  modelType: WiroModelType;
  effectType: string;
  videoMode: 'std' | 'pro';
  inputImage?: string;       // Base64 or URL for product image
  logoImage?: string;        // Base64 or URL for logo image
  caption?: string;          // Text caption
}

/** Response from Cloud Function to Flutter app */
export interface CloudFunctionRunTaskResponse {
  success: boolean;
  taskId?: string;
  socketToken?: string;
  error?: string;
}

export interface CloudFunctionTaskDetailResponse {
  success: boolean;
  task?: WiroTaskDetail;
  error?: string;
}
