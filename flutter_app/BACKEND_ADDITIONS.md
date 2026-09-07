# Backend additions needed for the Flutter app

The Flutter app calls a few endpoints that weren't in the original backend
endpoint list. Each is a small, natural extension of the existing modules
— none of them are new features, just plumbing the Flutter screens need.

---

## 1. GET /api/categories

Needed by: Select Category screen (customer) and Select Categories screen (worker).

**backend/src/modules/categories/category.routes.js** (new file)
```js
const express = require('express');
const router = express.Router();
const { pool } = require('../../config/db');
const asyncHandler = require('../../utils/asyncHandler');
const { success } = require('../../utils/response');
const { requireAuth } = require('../../middleware/authMiddleware');

router.get('/', requireAuth, asyncHandler(async (req, res) => {
  const [rows] = await pool.query('SELECT id, name, icon FROM categories WHERE is_active = 1');
  success(res, rows, 'Categories fetched');
}));

module.exports = router;
```

**backend/src/routes/index.js** — add:
```js
const categoryRoutes = require('../modules/categories/category.routes');
router.use('/categories', categoryRoutes);
```

---

## 2. PUT /api/users/fcm-token

Needed by: `fcm_service.dart`, so the backend knows which device token to
push notifications to.

**backend/src/modules/auth/auth.routes.js** — add:
```js
const { requireAuth } = require('../../middleware/authMiddleware');

router.put('/../users/fcm-token', requireAuth, asyncHandler(async (req, res) => {
  const { fcm_token } = req.body;
  await pool.query('UPDATE users SET fcm_token = ? WHERE id = ?', [fcm_token, req.user.id]);
  success(res, null, 'FCM token updated');
}));
```
(Cleaner: put this in a small `users` module instead — mount a
`user.routes.js` with `router.put('/fcm-token', ...)` at `/api/users`.)

---

## 3. GET /api/workers/history

Needed by: Work History screen (worker).

**backend/src/modules/workers/worker.routes.js** — add:
```js
router.get('/history', workerController.getHistory);
```

**backend/src/modules/workers/worker.service.js** — add:
```js
async function getHistory(userId) {
  const worker = await getWorkerByUserId(userId);
  const [rows] = await pool.query(
    `SELECT w.*, c.name AS category_name
     FROM works w
     JOIN categories c ON c.id = w.category_id
     WHERE w.accepted_worker_id = ?
     ORDER BY w.created_at DESC`,
    [worker.id]
  );
  return rows;
}
module.exports = { ...module.exports, getHistory };
```

**backend/src/modules/workers/worker.controller.js** — add:
```js
const getHistory = asyncHandler(async (req, res) => {
  const works = await workerService.getHistory(req.user.id);
  success(res, works, 'Work history fetched');
});
module.exports = { ...module.exports, getHistory };
```
