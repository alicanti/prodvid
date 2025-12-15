/**
 * Wiro API types
 */

export interface WiroRunTaskRequest {
  inputImage: string;
  effectType: string;
  videoMode: 'std' | 'pro';
  callbackUrl?: string;
}

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

