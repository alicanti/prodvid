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
exports.wiroCallback = exports.cancelWiroTask = exports.killWiroTask = exports.getWiroTaskDetail = exports.runWiroTask = void 0;
// Wiro functions
var functions_1 = require("./wiro/functions");
Object.defineProperty(exports, "runWiroTask", { enumerable: true, get: function () { return functions_1.runWiroTask; } });
Object.defineProperty(exports, "getWiroTaskDetail", { enumerable: true, get: function () { return functions_1.getWiroTaskDetail; } });
Object.defineProperty(exports, "killWiroTask", { enumerable: true, get: function () { return functions_1.killWiroTask; } });
Object.defineProperty(exports, "cancelWiroTask", { enumerable: true, get: function () { return functions_1.cancelWiroTask; } });
Object.defineProperty(exports, "wiroCallback", { enumerable: true, get: function () { return functions_1.wiroCallback; } });
// TODO: Add credit management functions
// export { checkCredits, deductCredits, addCredits } from './credits/functions';
// TODO: Add RevenueCat webhook handler
// export { revenuecatWebhook } from './revenuecat/functions';
//# sourceMappingURL=index.js.map