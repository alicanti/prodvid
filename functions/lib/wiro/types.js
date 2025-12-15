"use strict";
/**
 * Wiro API types
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.isTaskCompleted = exports.COMPLETED_STATUSES = void 0;
exports.COMPLETED_STATUSES = [
    'task_postprocess_end',
    'task_cancel',
];
const isTaskCompleted = (status) => {
    return exports.COMPLETED_STATUSES.includes(status);
};
exports.isTaskCompleted = isTaskCompleted;
//# sourceMappingURL=types.js.map