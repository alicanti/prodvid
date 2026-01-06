"use strict";
/**
 * ProdVid Cloud Functions
 *
 * All server-side logic including:
 * - Wiro API integration
 * - Credit management
 * - RevenueCat webhooks
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.revenuecatWebhook = exports.refundTaskCredits = exports.updateTaskStatus2 = exports.updateTaskWithWiroId = exports.prepareGeneration = exports.getUserCredits = exports.wiroCallback = exports.cancelWiroTask = exports.killWiroTask = exports.getWiroTaskDetail = exports.runWiroTask = void 0;
// Wiro functions
var functions_1 = require("./wiro/functions");
Object.defineProperty(exports, "runWiroTask", { enumerable: true, get: function () { return functions_1.runWiroTask; } });
Object.defineProperty(exports, "getWiroTaskDetail", { enumerable: true, get: function () { return functions_1.getWiroTaskDetail; } });
Object.defineProperty(exports, "killWiroTask", { enumerable: true, get: function () { return functions_1.killWiroTask; } });
Object.defineProperty(exports, "cancelWiroTask", { enumerable: true, get: function () { return functions_1.cancelWiroTask; } });
Object.defineProperty(exports, "wiroCallback", { enumerable: true, get: function () { return functions_1.wiroCallback; } });
Object.defineProperty(exports, "getUserCredits", { enumerable: true, get: function () { return functions_1.getUserCredits; } });
Object.defineProperty(exports, "prepareGeneration", { enumerable: true, get: function () { return functions_1.prepareGeneration; } });
Object.defineProperty(exports, "updateTaskWithWiroId", { enumerable: true, get: function () { return functions_1.updateTaskWithWiroId; } });
Object.defineProperty(exports, "updateTaskStatus2", { enumerable: true, get: function () { return functions_1.updateTaskStatus2; } });
Object.defineProperty(exports, "refundTaskCredits", { enumerable: true, get: function () { return functions_1.refundTaskCredits; } });
// RevenueCat webhook handler
var webhook_1 = require("./revenuecat/webhook");
Object.defineProperty(exports, "revenuecatWebhook", { enumerable: true, get: function () { return webhook_1.revenuecatWebhook; } });
//# sourceMappingURL=index.js.map