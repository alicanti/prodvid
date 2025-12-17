"use strict";
/**
 * Wiro API types
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.isTaskSuccessful = exports.isTaskCompleted = exports.COMPLETED_STATUSES = exports.WIRO_MODEL_ENDPOINTS = void 0;
exports.WIRO_MODEL_ENDPOINTS = {
    'wiro/3d-text-animations': 'https://api.wiro.ai/v1/Run/wiro/3d-text-animations',
    'wiro/product-ads': 'https://api.wiro.ai/v1/Run/wiro/product-ads',
    'wiro/product-ads-with-caption': 'https://api.wiro.ai/v1/Run/wiro/product-ads-with-caption',
    'wiro/product-ads-with-logo': 'https://api.wiro.ai/v1/Run/wiro/product-ads-with-logo',
};
exports.COMPLETED_STATUSES = [
    'task_postprocess_end',
    'task_cancel',
];
const isTaskCompleted = (status) => {
    return exports.COMPLETED_STATUSES.includes(status);
};
exports.isTaskCompleted = isTaskCompleted;
const isTaskSuccessful = (status) => {
    return status === 'task_postprocess_end';
};
exports.isTaskSuccessful = isTaskSuccessful;
//# sourceMappingURL=types.js.map