/*
 Navicat Premium Dump SQL

 Source Server         : root
 Source Server Type    : MySQL
 Source Server Version : 80044 (8.0.44)
 Source Host           : localhost:3306
 Source Schema         : krpano

 Target Server Type    : MySQL
 Target Server Version : 80044 (8.0.44)
 File Encoding         : 65001

 Date: 03/06/2026 10:25:57
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for analytics
-- ----------------------------
DROP TABLE IF EXISTS `analytics`;
CREATE TABLE `analytics`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `record_date` date NOT NULL COMMENT '记录日期',
  `page_views` int NULL DEFAULT 0 COMMENT '页面访问量 (PV)',
  `unique_visitors` int NULL DEFAULT 0 COMMENT '独立访客 (UV)',
  `avg_stay_time` int NULL DEFAULT 0 COMMENT '平均停留时长 (秒)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `record_date`(`record_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 53 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '每日数据统计表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of analytics
-- ----------------------------
INSERT INTO `analytics` VALUES (7, '2026-03-15', 2, 1, 29, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (8, '2026-03-16', 7, 2, 19, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (9, '2026-03-17', 7, 3, 16, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (10, '2026-03-18', 4, 1, 15, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (11, '2026-03-19', 5, 3, 28, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (12, '2026-03-20', 3, 2, 30, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (13, '2026-03-21', 14, 2, 80, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (14, '2026-03-22', 6, 3, 72, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (15, '2026-03-23', 18, 5, 48, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (16, '2026-03-24', 23, 3, 45, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (17, '2026-03-25', 24, 5, 31, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (18, '2026-03-26', 20, 4, 36, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (19, '2026-03-27', 15, 7, 23, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (20, '2026-03-28', 13, 4, 78, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (21, '2026-03-29', 13, 4, 66, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (22, '2026-03-30', 10, 4, 35, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (23, '2026-03-31', 16, 6, 67, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (24, '2026-04-01', 25, 9, 46, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (25, '2026-04-02', 27, 8, 103, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (26, '2026-04-03', 29, 9, 120, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (27, '2026-04-04', 26, 3, 46, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (28, '2026-04-05', 29, 3, 79, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (29, '2026-04-06', 44, 8, 99, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (30, '2026-04-07', 29, 10, 57, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (31, '2026-04-08', 27, 5, 95, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (32, '2026-04-09', 36, 10, 158, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (33, '2026-04-10', 35, 5, 50, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (34, '2026-04-11', 25, 3, 105, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (35, '2026-04-12', 26, 7, 120, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (36, '2026-04-13', 61, 13, 208, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (37, '2026-04-14', 43, 8, 225, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (38, '2026-04-15', 72, 14, 68, '2026-04-21 01:23:32');
INSERT INTO `analytics` VALUES (39, '2026-04-16', 48, 15, 101, '2026-04-21 01:23:33');
INSERT INTO `analytics` VALUES (40, '2026-04-17', 35, 15, 104, '2026-04-21 01:23:33');
INSERT INTO `analytics` VALUES (41, '2026-04-18', 43, 5, 82, '2026-04-21 01:23:33');
INSERT INTO `analytics` VALUES (42, '2026-04-19', 37, 7, 105, '2026-04-21 01:23:33');
INSERT INTO `analytics` VALUES (43, '2026-04-20', 52, 12, 74, '2026-04-21 01:23:33');
INSERT INTO `analytics` VALUES (44, '2026-04-21', 48, 10, 62, '2026-04-21 01:23:33');
INSERT INTO `analytics` VALUES (45, '2026-04-26', 8, 1, 0, '2026-04-27 01:12:15');
INSERT INTO `analytics` VALUES (46, '2026-04-28', 1, 1, 0, '2026-04-28 23:29:41');
INSERT INTO `analytics` VALUES (47, '2026-04-29', 53, 1, 0, '2026-04-29 12:29:27');
INSERT INTO `analytics` VALUES (48, '2026-05-04', 3, 1, 0, '2026-05-04 13:05:58');
INSERT INTO `analytics` VALUES (49, '2026-05-05', 1, 1, 0, '2026-05-05 18:41:55');
INSERT INTO `analytics` VALUES (50, '2026-05-08', 36, 3, 0, '2026-05-08 12:24:32');
INSERT INTO `analytics` VALUES (51, '2026-05-09', 13, 1, 0, '2026-05-09 14:15:31');
INSERT INTO `analytics` VALUES (52, '2026-05-10', 1, 1, 0, '2026-05-10 10:12:32');

-- ----------------------------
-- Table structure for chat_messages
-- ----------------------------
DROP TABLE IF EXISTS `chat_messages`;
CREATE TABLE `chat_messages`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `session_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '访客会话ID(唯一标识一个前台访客)',
  `sender_type` enum('visitor','admin','cs') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发送者类型',
  `sender_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发送者名称',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息内容',
  `message_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'text',
  `model_data` json NULL,
  `is_read` tinyint(1) NULL DEFAULT 0 COMMENT '是否已读(主要针对后台未读)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 60 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实时聊天记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of chat_messages
-- ----------------------------
INSERT INTO `chat_messages` VALUES (10, 'device_abc123', 'visitor', 'device_abc123', '你好，请问这个展厅可以手机浏览吗？', 'text', NULL, 1, '2026-04-04 10:20:00');
INSERT INTO `chat_messages` VALUES (11, 'device_abc123', 'cs', 'kefu1', '您好！可以的，手机浏览器直接访问即可', 'text', NULL, 1, '2026-04-04 10:22:00');
INSERT INTO `chat_messages` VALUES (12, 'device_abc123', 'visitor', 'device_abc123', '好的，谢谢！', 'text', NULL, 1, '2026-04-04 10:23:00');
INSERT INTO `chat_messages` VALUES (13, 'device_def456', 'visitor', 'device_def456', '3D模型打不开是怎么回事？', 'text', NULL, 1, '2026-04-07 14:30:00');
INSERT INTO `chat_messages` VALUES (14, 'device_def456', 'cs', 'kefu1', '您好，请问您使用的是什么浏览器？建议使用Chrome', 'text', NULL, 1, '2026-04-07 14:35:00');
INSERT INTO `chat_messages` VALUES (15, 'device_def456', 'visitor', 'device_def456', '换了Chrome可以了，谢谢', 'text', NULL, 1, '2026-04-07 14:40:00');
INSERT INTO `chat_messages` VALUES (16, 'device_ghi789', 'visitor', 'device_ghi789', '全景场景切换效果很流畅', 'text', NULL, 1, '2026-04-10 16:00:00');
INSERT INTO `chat_messages` VALUES (17, 'device_ghi789', 'cs', 'kefu2', '感谢您的认可！', 'text', NULL, 1, '2026-04-10 16:05:00');
INSERT INTO `chat_messages` VALUES (18, 'device_jkl012', 'visitor', 'device_jkl012', '请问魔方动画怎么操作？', 'text', NULL, 1, '2026-04-13 11:10:00');
INSERT INTO `chat_messages` VALUES (19, 'device_jkl012', 'cs', 'kefu1', '魔方动画是自动播放的，您也可以在3D模型展示页面切换查看', 'text', NULL, 1, '2026-04-13 11:15:00');
INSERT INTO `chat_messages` VALUES (20, 'device_mno345', 'visitor', 'device_mno345', '留言墙功能挺有意思的', 'text', NULL, 1, '2026-04-15 09:40:00');
INSERT INTO `chat_messages` VALUES (21, 'device_mno345', 'cs', 'kefu2', '谢谢，欢迎您留言互动！', 'text', NULL, 1, '2026-04-15 09:45:00');
INSERT INTO `chat_messages` VALUES (22, 'device_pqr678', 'visitor', 'device_pqr678', '机械零件的3D展示很详细', 'text', NULL, 1, '2026-04-18 14:20:00');
INSERT INTO `chat_messages` VALUES (23, 'device_pqr678', 'cs', 'kefu1', '感谢好评！后续还会增加更多模型', 'text', NULL, 1, '2026-04-18 14:25:00');
INSERT INTO `chat_messages` VALUES (24, 'device_pqr678', 'visitor', 'device_pqr678', '期待更新', 'text', NULL, 1, '2026-04-18 14:26:00');
INSERT INTO `chat_messages` VALUES (25, 'device_stu901', 'visitor', 'device_stu901', '请问这个项目支持VR设备吗？', 'text', NULL, 1, '2026-04-20 10:00:00');
INSERT INTO `chat_messages` VALUES (26, 'device_stu901', 'cs', 'kefu2', '目前支持WebVR模式，可以使用VR眼镜浏览全景', 'text', NULL, 1, '2026-04-20 10:05:00');
INSERT INTO `chat_messages` VALUES (27, '222', 'visitor', '222', '111', 'text', NULL, 1, '2026-04-21 18:34:25');
INSERT INTO `chat_messages` VALUES (28, 'zhangsan', 'visitor', 'zhangsan', '111', 'text', NULL, 1, '2026-04-21 18:35:22');
INSERT INTO `chat_messages` VALUES (29, 'zhangsan', 'admin', 'admin', '[模型信息] 零件9', 'model', '{\"model_key\": \"机械零件01-9\", \"model_name\": \"零件9\", \"module_key\": \"mechanical\", \"module_name\": \"机械零件\", \"model_params\": {\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"hhh\", \"speed_unit\": \"rpm\", \"runtime_unit\": \"h\", \"capacity_unit\": \"L\"}}', 0, '2026-04-21 19:34:48');
INSERT INTO `chat_messages` VALUES (30, 'wangwu', 'visitor', 'wangwu', '111', 'text', NULL, 1, '2026-04-28 23:30:10');
INSERT INTO `chat_messages` VALUES (31, 'wangwu', 'visitor', 'wangwu', '111', 'text', NULL, 1, '2026-04-28 23:30:19');
INSERT INTO `chat_messages` VALUES (32, 'wangwu', 'visitor', 'wangwu', 'aaa', 'text', NULL, 1, '2026-04-29 12:48:47');
INSERT INTO `chat_messages` VALUES (33, 'wangwu', 'admin', 'admin', '111', 'text', NULL, 0, '2026-04-29 12:48:54');
INSERT INTO `chat_messages` VALUES (34, 'wangwu', 'admin', 'admin', '222', 'text', NULL, 0, '2026-04-29 12:50:41');
INSERT INTO `chat_messages` VALUES (35, 'wangwu', 'admin', 'admin', '333', 'text', NULL, 0, '2026-04-29 12:50:42');
INSERT INTO `chat_messages` VALUES (36, 'wangwu', 'admin', 'admin', '444', 'text', NULL, 0, '2026-04-29 15:06:41');
INSERT INTO `chat_messages` VALUES (37, 'admin', 'visitor', 'admin', '你的设备很有意思', 'text', NULL, 1, '2026-05-05 18:43:55');
INSERT INTO `chat_messages` VALUES (38, 'zhangsan', 'visitor', 'zhangsan', '123', 'text', NULL, 1, '2026-05-08 16:12:32');
INSERT INTO `chat_messages` VALUES (39, 'zhangsan', 'admin', 'admin', 'www', 'text', NULL, 0, '2026-05-08 16:50:39');
INSERT INTO `chat_messages` VALUES (40, 'zhangsan', 'visitor', 'zhangsan', 'qqq', 'text', NULL, 1, '2026-05-08 16:51:08');
INSERT INTO `chat_messages` VALUES (41, 'zhangsan', 'cs', 'zhangsan', '111', 'text', NULL, 0, '2026-05-08 16:56:22');
INSERT INTO `chat_messages` VALUES (42, 'zhangsan', 'admin', 'admin', 'qqq', 'text', NULL, 0, '2026-05-08 17:23:31');
INSERT INTO `chat_messages` VALUES (43, 'zhangsan', 'admin', 'admin', '111', 'text', NULL, 0, '2026-05-08 17:23:42');
INSERT INTO `chat_messages` VALUES (44, 'zhangsan', 'visitor', 'zhangsan', '222', 'text', NULL, 1, '2026-05-08 17:24:35');
INSERT INTO `chat_messages` VALUES (45, 'zhangsan', 'visitor', 'zhangsan', '333', 'text', NULL, 1, '2026-05-08 17:24:48');
INSERT INTO `chat_messages` VALUES (46, 'zhangsan', 'admin', 'admin', '444', 'text', NULL, 0, '2026-05-08 17:25:20');
INSERT INTO `chat_messages` VALUES (47, 'lisi', 'visitor', 'lisi', '111', 'text', NULL, 1, '2026-05-09 14:17:26');
INSERT INTO `chat_messages` VALUES (48, 'lisi', 'admin', 'admin', '111', 'text', NULL, 0, '2026-05-09 14:17:32');
INSERT INTO `chat_messages` VALUES (49, 'lisi', 'admin', 'admin', '222', 'text', NULL, 0, '2026-05-09 14:17:37');
INSERT INTO `chat_messages` VALUES (50, 'lisi', 'admin', 'admin', '[模型信息] 零件1', 'model', '{\"model_key\": \"机械零件01-1\", \"model_name\": \"零件1\", \"module_key\": \"mechanical\", \"module_name\": \"机械零件\", \"model_params\": {\"batch\": \"32万份\", \"speed\": \"84\", \"runtime\": \"2025-3\", \"capacity\": \"1234\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}}', 0, '2026-05-09 14:17:44');
INSERT INTO `chat_messages` VALUES (51, 'lisi', 'cs', 'kefu1', '222', 'text', NULL, 0, '2026-05-09 14:25:54');
INSERT INTO `chat_messages` VALUES (52, 'lisi', 'visitor', 'lisi', 'qwe', 'text', NULL, 1, '2026-05-10 00:02:54');
INSERT INTO `chat_messages` VALUES (53, 'lisi', 'admin', 'admin', '222', 'text', NULL, 0, '2026-05-10 00:03:00');
INSERT INTO `chat_messages` VALUES (54, 'lisi', 'visitor', 'lisi', '111', 'text', NULL, 1, '2026-05-10 00:04:52');
INSERT INTO `chat_messages` VALUES (55, 'lisi', 'admin', 'admin', '222', 'text', NULL, 0, '2026-05-10 00:04:58');
INSERT INTO `chat_messages` VALUES (56, 'lisi', 'visitor', 'lisi', '333', 'text', NULL, 1, '2026-05-10 00:07:14');
INSERT INTO `chat_messages` VALUES (57, 'lisi', 'admin', 'admin', '444', 'text', NULL, 0, '2026-05-10 00:08:07');
INSERT INTO `chat_messages` VALUES (58, 'lisi', 'visitor', 'lisi', '222', 'text', NULL, 1, '2026-05-10 10:14:31');
INSERT INTO `chat_messages` VALUES (59, 'lisi', 'admin', 'admin', '11', 'text', NULL, 0, '2026-05-10 10:14:42');

-- ----------------------------
-- Table structure for messages
-- ----------------------------
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '留言用户昵称',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '留言内容',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态: 0-待审核, 1-已通过, 2-已拒绝',
  `is_top` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否置顶: 0-否, 1-是',
  `reply_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '回复内容',
  `replier_role` enum('admin','cs') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '回复人角色',
  `reply_time` timestamp NULL DEFAULT NULL COMMENT '回复时间',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '留言时间',
  `likes` int NULL DEFAULT 0 COMMENT '点赞数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '留言墙表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of messages
-- ----------------------------
INSERT INTO `messages` VALUES (9, '开发者', '测试留言功能是否正常', 1, 0, NULL, NULL, NULL, '2026-03-22 10:15:00', 0);
INSERT INTO `messages` VALUES (10, '开发者', '留言墙功能已上线', 1, 0, NULL, NULL, NULL, '2026-03-22 10:20:00', 0);
INSERT INTO `messages` VALUES (11, '张三', '全景展厅效果很棒！', 1, 0, '感谢您的认可！', 'admin', '2026-03-28 16:00:00', '2026-03-28 15:30:00', 0);
INSERT INTO `messages` VALUES (12, '李四', '请问3D模型可以旋转查看吗？', 1, 0, '可以的，鼠标拖拽即可旋转模型', 'cs', '2026-04-03 11:45:00', '2026-04-03 11:20:00', 0);
INSERT INTO `messages` VALUES (13, '王五', '机械零件展示很清晰，点赞！', 1, 0, NULL, NULL, NULL, '2026-04-06 14:10:00', 0);
INSERT INTO `messages` VALUES (14, '访客', '希望能增加更多场景', 1, 0, '感谢建议，后续会持续更新', 'admin', '2026-04-09 10:00:00', '2026-04-09 09:30:00', 3);
INSERT INTO `messages` VALUES (15, '赵六', '魔方动画很有意思', 1, 0, NULL, NULL, NULL, '2026-04-11 16:45:00', 0);
INSERT INTO `messages` VALUES (16, '孙七', '在手机上也能正常浏览，体验不错', 1, 0, NULL, NULL, NULL, '2026-04-13 20:15:00', 0);
INSERT INTO `messages` VALUES (17, '周八', '请问这个项目用的什么技术？', 0, 0, NULL, NULL, NULL, '2026-04-15 10:30:00', 0);
INSERT INTO `messages` VALUES (18, '测试用户', '测试审核功能', 2, 0, NULL, NULL, NULL, '2026-04-16 14:00:00', 0);
INSERT INTO `messages` VALUES (19, '张三', '再次来访，越来越好了', 1, 1, '感谢持续关注！', 'cs', '2026-04-18 11:30:00', '2026-04-18 11:20:00', 2);
INSERT INTO `messages` VALUES (20, '访客', '场景切换很流畅', 1, 0, NULL, NULL, NULL, '2026-04-19 09:50:00', 0);
INSERT INTO `messages` VALUES (21, '李四', '客服回复很及时，好评', 1, 0, NULL, NULL, NULL, '2026-04-20 15:40:00', 2);
INSERT INTO `messages` VALUES (22, 'admin', '这是一个测试', 0, 0, NULL, NULL, NULL, '2026-05-05 18:42:56', 0);
INSERT INTO `messages` VALUES (23, 'zhangsan', '111', 1, 0, NULL, NULL, NULL, '2026-05-09 14:17:11', 0);
INSERT INTO `messages` VALUES (24, 'lisi', '111\n', 1, 0, NULL, NULL, NULL, '2026-05-10 00:01:59', 1);
INSERT INTO `messages` VALUES (25, 'lisi', '333', 1, 0, NULL, NULL, NULL, '2026-05-10 00:05:15', 1);
INSERT INTO `messages` VALUES (26, 'lisi', '444', 1, 0, NULL, NULL, NULL, '2026-05-10 00:07:09', 0);
INSERT INTO `messages` VALUES (27, 'lisi', '44\n', 1, 0, '333', 'admin', '2026-05-10 10:13:30', '2026-05-10 10:13:08', 0);
INSERT INTO `messages` VALUES (28, 'lisi', '123456', 1, 0, NULL, NULL, NULL, '2026-05-10 10:16:17', 0);

-- ----------------------------
-- Table structure for model_display
-- ----------------------------
DROP TABLE IF EXISTS `model_display`;
CREATE TABLE `model_display`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `module_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模块标识',
  `module_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模块名称',
  `model_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '模型标识',
  `model_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '模型名称',
  `is_enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用',
  `disable_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '禁用理由',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后操作人',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `model_params` json NULL COMMENT '模型参数(信息卡片内容)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_module_model`(`module_key` ASC, `model_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '3D模型展示控制表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of model_display
-- ----------------------------
INSERT INTO `model_display` VALUES (1, 'mechanical', '机械零件', NULL, NULL, 1, NULL, NULL, '2026-04-20 23:24:37', NULL);
INSERT INTO `model_display` VALUES (2, 'cube', '魔方动画', NULL, NULL, 1, NULL, 'admin', '2026-04-21 01:48:53', NULL);
INSERT INTO `model_display` VALUES (3, 'mechanical', '机械零件', '机械零件01-底座', '底座', 1, NULL, 'admin', '2026-05-08 19:25:50', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (4, 'mechanical', '机械零件', '机械零件01-1', '零件1', 1, NULL, 'admin', '2026-05-10 00:08:49', '{\"batch\": \"32万份\", \"speed\": \"84\", \"runtime\": \"2025-3\", \"capacity\": \"1234\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (5, 'mechanical', '机械零件', '机械零件01-2', '零件2', 1, NULL, 'admin', '2026-05-08 19:24:17', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (6, 'mechanical', '机械零件', '机械零件01-3', '零件3', 1, NULL, 'admin', '2026-05-08 19:24:35', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (7, 'mechanical', '机械零件', '机械零件01-4', '零件4', 1, NULL, 'admin', '2026-05-08 19:24:53', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (8, 'mechanical', '机械零件', '机械零件01-5', '零件5', 1, NULL, 'admin', '2026-05-08 19:25:07', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (9, 'mechanical', '机械零件', '机械零件01-6', '零件6', 1, NULL, 'admin', '2026-05-08 19:25:16', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (10, 'mechanical', '机械零件', '机械零件01-7', '零件7', 1, NULL, 'admin', '2026-05-08 19:25:26', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (11, 'mechanical', '机械零件', '机械零件01-8', '零件8', 1, NULL, 'admin', '2026-05-08 19:25:35', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (12, 'mechanical', '机械零件', '机械零件01-9', '零件9', 1, NULL, 'admin', '2026-05-08 19:25:42', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (13, 'mechanical', '机械零件', '机械零件01-10', '零件10', 1, NULL, 'admin', '2026-05-08 19:20:54', '{\"batch\": \"45万份\", \"speed\": \"99\", \"runtime\": \"2024-3\", \"capacity\": \"443\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (14, 'mechanical', '机械零件', '机械零件01-11', '零件11', 1, NULL, 'admin', '2026-05-08 19:22:16', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (15, 'mechanical', '机械零件', '机械零件01-12', '零件12', 1, NULL, 'admin', '2026-05-08 19:22:27', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (16, 'mechanical', '机械零件', '机械零件01-13', '零件13', 1, NULL, 'admin', '2026-05-08 19:22:40', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (17, 'mechanical', '机械零件', '机械零件01-14', '零件14', 1, NULL, 'admin', '2026-05-08 19:23:14', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (18, 'mechanical', '机械零件', '机械零件01-15', '零件15', 1, NULL, 'admin', '2026-05-08 19:23:30', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (19, 'mechanical', '机械零件', '机械零件01-16', '零件16', 1, NULL, 'admin', '2026-05-08 19:23:47', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (20, 'mechanical', '机械零件', '机械零件01-17', '零件17', 1, NULL, 'admin', '2026-05-08 19:23:56', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (21, 'mechanical', '机械零件', '机械零件01-18', '零件18', 1, NULL, 'admin', '2026-05-08 19:24:07', '{\"batch\": \"abc\", \"speed\": \"123\", \"runtime\": \"456\", \"capacity\": \"123\", \"model_type\": \"jxlj-01\", \"speed_unit\": \"%\", \"runtime_unit\": \"月\", \"capacity_unit\": \"元\"}');
INSERT INTO `model_display` VALUES (22, 'cube', '魔方动画', '魔方', '魔方模型', 1, NULL, 'admin', '2026-05-10 00:03:19', '{\"batch\": \"暂无\", \"speed\": \"暂无\", \"runtime\": \"暂无\", \"capacity\": \"暂无\", \"model_type\": \"3x3\", \"speed_unit\": \"%\", \"runtime_unit\": \"\", \"capacity_unit\": \"元\"}');

-- ----------------------------
-- Table structure for settings
-- ----------------------------
DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '企业360全景线上展厅',
  `logo_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '',
  `target_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'https://www.krpano.com',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `demo_mode` tinyint(1) NULL DEFAULT 0 COMMENT '答辩演示模式 (开启后允许重复点赞)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '网站配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of settings
-- ----------------------------
INSERT INTO `settings` VALUES (1, '企业360全景线上展厅', '../images/logo.png', 'https://www.krpano.com', '2026-04-29 14:15:51', 0);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码 (建议存储哈希值)',
  `role` enum('admin','cs','user') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'user' COMMENT '角色: admin-管理员, cs-客服, user-普通用户',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '后台账号表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin', '$2b$10$xzNm7eMgm2QRb8FHzyjHUO0ql6/HhDJP6/aB0CsGRu6S3Tba/JyDO', 'admin', '2026-04-13 20:55:41');
INSERT INTO `users` VALUES (5, 'kefu1', '$2b$10$8NvNxE1MS91tn47m5dP1ieupzdUhZ4NcyYabUJtNglPyN6gKzk6FS', 'cs', '2026-04-02 09:00:00');
INSERT INTO `users` VALUES (6, 'kefu2', '123456', 'cs', '2026-04-05 10:30:00');
INSERT INTO `users` VALUES (7, 'zhangsan', '$2b$10$KPoy8b7Zqjolqh7AsIXTq.s00Wuoj5GitBW0.FWvOwb/j2EgwYzXu', 'user', '2026-03-20 14:22:00');
INSERT INTO `users` VALUES (8, 'lisi', '$2b$10$JJUhmD74JT3IniJw9te.qu/g4CM4Z2kvkNnNnIYAw9IMeQy3S5aYO', 'user', '2026-03-25 16:45:00');
INSERT INTO `users` VALUES (9, 'wangwu', '$2b$10$QaMN6mUhqe0iPAKQVRuGYePrG0HgRsn26GowrIhtXp0pJAXKJMAwS', 'user', '2026-04-01 11:10:00');
INSERT INTO `users` VALUES (10, 'zhaoliu', '123456', 'user', '2026-04-03 09:55:00');
INSERT INTO `users` VALUES (11, 'sunqi', '123456', 'user', '2026-04-08 15:30:00');
INSERT INTO `users` VALUES (12, 'zhouba', '123456', 'user', '2026-04-12 20:18:00');

-- ----------------------------
-- Table structure for visit_logs
-- ----------------------------
DROP TABLE IF EXISTS `visit_logs`;
CREATE TABLE `visit_logs`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `session_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会话ID',
  `visit_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '访问时间',
  `stay_duration` int NULL DEFAULT 0 COMMENT '停留时长(秒)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 496 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '访问记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of visit_logs
-- ----------------------------
INSERT INTO `visit_logs` VALUES (12, 'device_bcd890', '2026-03-15 16:06:39', 25);
INSERT INTO `visit_logs` VALUES (13, 'device_mno345', '2026-03-15 13:37:48', 13);
INSERT INTO `visit_logs` VALUES (14, 'device_ghi789', '2026-03-15 10:28:24', 31);
INSERT INTO `visit_logs` VALUES (15, 'device_mno345', '2026-03-16 20:32:33', 44);
INSERT INTO `visit_logs` VALUES (16, 'device_abc123', '2026-03-16 18:05:47', 19);
INSERT INTO `visit_logs` VALUES (17, 'device_mno345', '2026-03-16 17:29:00', 26);
INSERT INTO `visit_logs` VALUES (18, 'device_efg111', '2026-03-16 09:24:07', 10);
INSERT INTO `visit_logs` VALUES (19, 'device_vwx234', '2026-03-17 17:31:13', 33);
INSERT INTO `visit_logs` VALUES (20, 'device_pqr678', '2026-03-17 13:37:12', 45);
INSERT INTO `visit_logs` VALUES (21, 'device_jkl012', '2026-03-17 17:47:18', 7);
INSERT INTO `visit_logs` VALUES (22, 'device_bcd890', '2026-03-18 15:39:39', 8);
INSERT INTO `visit_logs` VALUES (23, 'device_jkl012', '2026-03-18 12:16:21', 42);
INSERT INTO `visit_logs` VALUES (24, 'device_stu901', '2026-03-18 20:15:40', 24);
INSERT INTO `visit_logs` VALUES (25, 'device_def456', '2026-03-19 21:54:43', 45);
INSERT INTO `visit_logs` VALUES (26, 'device_mno345', '2026-03-19 12:39:15', 11);
INSERT INTO `visit_logs` VALUES (27, 'device_yza567', '2026-03-19 17:02:58', 9);
INSERT INTO `visit_logs` VALUES (28, 'device_vwx234', '2026-03-19 15:49:11', 36);
INSERT INTO `visit_logs` VALUES (29, 'device_mno345', '2026-03-20 16:59:30', 16);
INSERT INTO `visit_logs` VALUES (30, 'device_abc123', '2026-03-20 10:26:47', 11);
INSERT INTO `visit_logs` VALUES (31, 'device_vwx234', '2026-03-21 18:55:14', 116);
INSERT INTO `visit_logs` VALUES (32, 'device_ghi789', '2026-03-21 13:08:15', 110);
INSERT INTO `visit_logs` VALUES (33, 'device_stu901', '2026-03-21 11:40:52', 50);
INSERT INTO `visit_logs` VALUES (34, 'device_jkl012', '2026-03-21 18:11:59', 28);
INSERT INTO `visit_logs` VALUES (35, 'device_yza567', '2026-03-22 17:37:24', 61);
INSERT INTO `visit_logs` VALUES (36, 'device_vwx234', '2026-03-22 19:20:58', 51);
INSERT INTO `visit_logs` VALUES (37, 'device_vwx234', '2026-03-22 22:45:02', 82);
INSERT INTO `visit_logs` VALUES (38, 'device_efg111', '2026-03-22 09:48:27', 41);
INSERT INTO `visit_logs` VALUES (39, 'device_stu901', '2026-03-23 09:50:21', 97);
INSERT INTO `visit_logs` VALUES (40, 'device_abc123', '2026-03-23 15:20:46', 72);
INSERT INTO `visit_logs` VALUES (41, 'device_hij222', '2026-03-23 17:03:47', 22);
INSERT INTO `visit_logs` VALUES (42, 'device_yza567', '2026-03-23 16:57:52', 69);
INSERT INTO `visit_logs` VALUES (43, 'device_hij222', '2026-03-23 11:14:23', 52);
INSERT INTO `visit_logs` VALUES (44, 'device_efg111', '2026-03-23 10:04:16', 7);
INSERT INTO `visit_logs` VALUES (45, 'device_mno345', '2026-03-23 21:43:09', 101);
INSERT INTO `visit_logs` VALUES (46, 'device_def456', '2026-03-24 08:00:54', 56);
INSERT INTO `visit_logs` VALUES (47, 'device_bcd890', '2026-03-24 21:40:13', 66);
INSERT INTO `visit_logs` VALUES (48, 'device_mno345', '2026-03-24 19:32:03', 70);
INSERT INTO `visit_logs` VALUES (49, 'device_vwx234', '2026-03-24 20:26:10', 62);
INSERT INTO `visit_logs` VALUES (50, 'device_ghi789', '2026-03-24 18:12:08', 87);
INSERT INTO `visit_logs` VALUES (51, 'device_abc123', '2026-03-24 10:26:42', 86);
INSERT INTO `visit_logs` VALUES (52, 'device_hij222', '2026-03-25 19:00:43', 103);
INSERT INTO `visit_logs` VALUES (53, 'device_ghi789', '2026-03-25 11:06:01', 53);
INSERT INTO `visit_logs` VALUES (54, 'device_bcd890', '2026-03-25 08:15:56', 95);
INSERT INTO `visit_logs` VALUES (55, 'device_bcd890', '2026-03-25 09:48:10', 110);
INSERT INTO `visit_logs` VALUES (56, 'device_vwx234', '2026-03-25 11:31:35', 117);
INSERT INTO `visit_logs` VALUES (57, 'device_abc123', '2026-03-25 20:41:36', 35);
INSERT INTO `visit_logs` VALUES (58, 'device_ghi789', '2026-03-26 16:54:10', 12);
INSERT INTO `visit_logs` VALUES (59, 'device_abc123', '2026-03-26 13:19:35', 105);
INSERT INTO `visit_logs` VALUES (60, 'device_pqr678', '2026-03-26 18:05:10', 102);
INSERT INTO `visit_logs` VALUES (61, 'device_vwx234', '2026-03-26 14:47:29', 66);
INSERT INTO `visit_logs` VALUES (62, 'device_def456', '2026-03-26 09:40:15', 39);
INSERT INTO `visit_logs` VALUES (63, 'device_abc123', '2026-03-26 21:28:22', 113);
INSERT INTO `visit_logs` VALUES (64, 'device_mno345', '2026-03-26 12:05:39', 18);
INSERT INTO `visit_logs` VALUES (65, 'device_vwx234', '2026-03-26 10:47:22', 24);
INSERT INTO `visit_logs` VALUES (66, 'device_pqr678', '2026-03-27 10:15:46', 116);
INSERT INTO `visit_logs` VALUES (67, 'device_yza567', '2026-03-27 17:20:36', 93);
INSERT INTO `visit_logs` VALUES (68, 'device_ghi789', '2026-03-27 10:03:43', 13);
INSERT INTO `visit_logs` VALUES (69, 'device_vwx234', '2026-03-27 18:25:14', 9);
INSERT INTO `visit_logs` VALUES (70, 'device_mno345', '2026-03-28 19:30:46', 16);
INSERT INTO `visit_logs` VALUES (71, 'device_hij222', '2026-03-28 09:49:10', 19);
INSERT INTO `visit_logs` VALUES (72, 'device_pqr678', '2026-03-28 08:52:23', 7);
INSERT INTO `visit_logs` VALUES (73, 'device_ghi789', '2026-03-29 08:06:23', 51);
INSERT INTO `visit_logs` VALUES (74, 'device_jkl012', '2026-03-29 09:44:17', 63);
INSERT INTO `visit_logs` VALUES (75, 'device_pqr678', '2026-03-29 09:42:55', 102);
INSERT INTO `visit_logs` VALUES (76, 'device_hij222', '2026-03-29 17:01:24', 78);
INSERT INTO `visit_logs` VALUES (77, 'device_def456', '2026-03-29 10:58:10', 111);
INSERT INTO `visit_logs` VALUES (78, 'device_yza567', '2026-03-30 22:16:38', 19);
INSERT INTO `visit_logs` VALUES (79, 'device_pqr678', '2026-03-30 14:58:16', 104);
INSERT INTO `visit_logs` VALUES (80, 'device_pqr678', '2026-03-30 11:54:06', 114);
INSERT INTO `visit_logs` VALUES (81, 'device_vwx234', '2026-03-30 22:55:02', 79);
INSERT INTO `visit_logs` VALUES (82, 'device_mno345', '2026-03-30 14:46:00', 117);
INSERT INTO `visit_logs` VALUES (83, 'device_stu901', '2026-03-30 11:21:59', 100);
INSERT INTO `visit_logs` VALUES (84, 'device_mno345', '2026-03-30 11:07:06', 25);
INSERT INTO `visit_logs` VALUES (85, 'device_ghi789', '2026-03-31 20:17:22', 31);
INSERT INTO `visit_logs` VALUES (86, 'device_mno345', '2026-03-31 13:23:37', 103);
INSERT INTO `visit_logs` VALUES (87, 'device_abc123', '2026-03-31 17:01:59', 37);
INSERT INTO `visit_logs` VALUES (88, 'device_efg111', '2026-03-31 16:21:10', 67);
INSERT INTO `visit_logs` VALUES (89, 'device_mno345', '2026-03-31 21:35:23', 11);
INSERT INTO `visit_logs` VALUES (90, 'device_mno345', '2026-04-01 21:20:26', 452);
INSERT INTO `visit_logs` VALUES (91, 'device_mno345', '2026-04-01 20:59:28', 133);
INSERT INTO `visit_logs` VALUES (92, 'device_pqr678', '2026-04-01 17:31:42', 537);
INSERT INTO `visit_logs` VALUES (93, 'device_vwx234', '2026-04-01 19:28:38', 15);
INSERT INTO `visit_logs` VALUES (94, 'device_hij222', '2026-04-01 22:14:24', 59);
INSERT INTO `visit_logs` VALUES (95, 'device_jkl012', '2026-04-01 14:42:54', 69);
INSERT INTO `visit_logs` VALUES (96, 'device_pqr678', '2026-04-01 22:36:40', 286);
INSERT INTO `visit_logs` VALUES (97, 'device_efg111', '2026-04-01 17:13:46', 117);
INSERT INTO `visit_logs` VALUES (98, 'device_vwx234', '2026-04-01 09:13:47', 101);
INSERT INTO `visit_logs` VALUES (99, 'device_bcd890', '2026-04-02 09:24:22', 4);
INSERT INTO `visit_logs` VALUES (100, 'device_ghi789', '2026-04-02 08:32:45', 215);
INSERT INTO `visit_logs` VALUES (101, 'device_mno345', '2026-04-02 09:45:44', 127);
INSERT INTO `visit_logs` VALUES (102, 'device_yza567', '2026-04-02 21:03:52', 70);
INSERT INTO `visit_logs` VALUES (103, 'device_ghi789', '2026-04-02 14:11:40', 33);
INSERT INTO `visit_logs` VALUES (104, 'device_stu901', '2026-04-02 17:59:20', 42);
INSERT INTO `visit_logs` VALUES (105, 'device_abc123', '2026-04-02 11:50:47', 9);
INSERT INTO `visit_logs` VALUES (106, 'device_ghi789', '2026-04-03 19:43:43', 494);
INSERT INTO `visit_logs` VALUES (107, 'device_stu901', '2026-04-03 20:06:32', 31);
INSERT INTO `visit_logs` VALUES (108, 'device_bcd890', '2026-04-03 21:29:21', 26);
INSERT INTO `visit_logs` VALUES (109, 'device_jkl012', '2026-04-03 12:53:44', 16);
INSERT INTO `visit_logs` VALUES (110, 'device_ghi789', '2026-04-03 10:05:36', 394);
INSERT INTO `visit_logs` VALUES (111, 'device_vwx234', '2026-04-03 20:15:28', 40);
INSERT INTO `visit_logs` VALUES (112, 'device_vwx234', '2026-04-03 10:47:06', 4);
INSERT INTO `visit_logs` VALUES (113, 'device_stu901', '2026-04-03 16:54:26', 10);
INSERT INTO `visit_logs` VALUES (114, 'device_bcd890', '2026-04-03 09:13:11', 43);
INSERT INTO `visit_logs` VALUES (115, 'device_abc123', '2026-04-03 15:23:19', 422);
INSERT INTO `visit_logs` VALUES (116, 'device_stu901', '2026-04-03 15:44:09', 19);
INSERT INTO `visit_logs` VALUES (117, 'device_hij222', '2026-04-03 21:17:07', 47);
INSERT INTO `visit_logs` VALUES (118, 'device_def456', '2026-04-04 17:10:07', 49);
INSERT INTO `visit_logs` VALUES (119, 'device_yza567', '2026-04-04 19:05:50', 235);
INSERT INTO `visit_logs` VALUES (120, 'device_yza567', '2026-04-04 22:47:07', 4);
INSERT INTO `visit_logs` VALUES (121, 'device_yza567', '2026-04-04 17:17:39', 70);
INSERT INTO `visit_logs` VALUES (122, 'device_abc123', '2026-04-04 20:50:30', 54);
INSERT INTO `visit_logs` VALUES (123, 'device_ghi789', '2026-04-04 14:07:00', 179);
INSERT INTO `visit_logs` VALUES (124, 'device_bcd890', '2026-04-05 21:25:52', 77);
INSERT INTO `visit_logs` VALUES (125, 'device_jkl012', '2026-04-05 08:05:25', 85);
INSERT INTO `visit_logs` VALUES (126, 'device_vwx234', '2026-04-05 19:57:02', 6);
INSERT INTO `visit_logs` VALUES (127, 'device_ghi789', '2026-04-05 15:12:01', 278);
INSERT INTO `visit_logs` VALUES (128, 'device_vwx234', '2026-04-05 14:25:51', 592);
INSERT INTO `visit_logs` VALUES (129, 'device_jkl012', '2026-04-05 11:31:00', 226);
INSERT INTO `visit_logs` VALUES (130, 'device_stu901', '2026-04-05 11:51:45', 8);
INSERT INTO `visit_logs` VALUES (131, 'device_pqr678', '2026-04-05 17:57:55', 468);
INSERT INTO `visit_logs` VALUES (132, 'device_mno345', '2026-04-06 11:13:45', 31);
INSERT INTO `visit_logs` VALUES (133, 'device_bcd890', '2026-04-06 14:22:12', 79);
INSERT INTO `visit_logs` VALUES (134, 'device_def456', '2026-04-06 17:08:48', 56);
INSERT INTO `visit_logs` VALUES (135, 'device_stu901', '2026-04-06 20:11:40', 56);
INSERT INTO `visit_logs` VALUES (136, 'device_def456', '2026-04-06 15:51:04', 367);
INSERT INTO `visit_logs` VALUES (137, 'device_ghi789', '2026-04-06 19:09:39', 62);
INSERT INTO `visit_logs` VALUES (138, 'device_bcd890', '2026-04-06 09:33:29', 20);
INSERT INTO `visit_logs` VALUES (139, 'device_hij222', '2026-04-06 20:33:56', 579);
INSERT INTO `visit_logs` VALUES (140, 'device_hij222', '2026-04-06 22:17:43', 286);
INSERT INTO `visit_logs` VALUES (141, 'device_efg111', '2026-04-06 22:10:23', 307);
INSERT INTO `visit_logs` VALUES (142, 'device_efg111', '2026-04-06 11:41:46', 307);
INSERT INTO `visit_logs` VALUES (143, 'device_vwx234', '2026-04-06 09:04:57', 42);
INSERT INTO `visit_logs` VALUES (144, 'device_bcd890', '2026-04-07 15:51:30', 220);
INSERT INTO `visit_logs` VALUES (145, 'device_mno345', '2026-04-07 09:51:50', 4);
INSERT INTO `visit_logs` VALUES (146, 'device_mno345', '2026-04-07 18:18:35', 7);
INSERT INTO `visit_logs` VALUES (147, 'device_bcd890', '2026-04-07 22:49:33', 368);
INSERT INTO `visit_logs` VALUES (148, 'device_pqr678', '2026-04-07 08:27:27', 32);
INSERT INTO `visit_logs` VALUES (149, 'device_pqr678', '2026-04-07 19:30:34', 141);
INSERT INTO `visit_logs` VALUES (150, 'device_yza567', '2026-04-07 19:45:38', 112);
INSERT INTO `visit_logs` VALUES (151, 'device_yza567', '2026-04-07 22:30:18', 15);
INSERT INTO `visit_logs` VALUES (152, 'device_stu901', '2026-04-07 11:44:21', 13);
INSERT INTO `visit_logs` VALUES (153, 'device_abc123', '2026-04-07 18:32:06', 44);
INSERT INTO `visit_logs` VALUES (154, 'device_yza567', '2026-04-07 17:41:26', 11);
INSERT INTO `visit_logs` VALUES (155, 'device_pqr678', '2026-04-07 18:01:36', 4);
INSERT INTO `visit_logs` VALUES (156, 'device_hij222', '2026-04-08 09:45:22', 572);
INSERT INTO `visit_logs` VALUES (157, 'device_mno345', '2026-04-08 21:52:36', 281);
INSERT INTO `visit_logs` VALUES (158, 'device_stu901', '2026-04-08 17:40:08', 453);
INSERT INTO `visit_logs` VALUES (159, 'device_yza567', '2026-04-08 19:35:35', 215);
INSERT INTO `visit_logs` VALUES (160, 'device_yza567', '2026-04-08 12:29:27', 116);
INSERT INTO `visit_logs` VALUES (161, 'device_stu901', '2026-04-08 17:40:32', 105);
INSERT INTO `visit_logs` VALUES (162, 'device_stu901', '2026-04-09 17:04:40', 474);
INSERT INTO `visit_logs` VALUES (163, 'device_ghi789', '2026-04-09 13:39:25', 25);
INSERT INTO `visit_logs` VALUES (164, 'device_mno345', '2026-04-09 20:21:26', 559);
INSERT INTO `visit_logs` VALUES (165, 'device_def456', '2026-04-09 13:53:45', 543);
INSERT INTO `visit_logs` VALUES (166, 'device_efg111', '2026-04-09 17:24:54', 54);
INSERT INTO `visit_logs` VALUES (167, 'device_efg111', '2026-04-09 11:00:19', 6);
INSERT INTO `visit_logs` VALUES (168, 'device_mno345', '2026-04-09 10:34:59', 7);
INSERT INTO `visit_logs` VALUES (169, 'device_vwx234', '2026-04-10 18:51:56', 359);
INSERT INTO `visit_logs` VALUES (170, 'device_stu901', '2026-04-10 13:00:46', 107);
INSERT INTO `visit_logs` VALUES (171, 'device_efg111', '2026-04-10 16:23:14', 3);
INSERT INTO `visit_logs` VALUES (172, 'device_vwx234', '2026-04-10 22:48:59', 224);
INSERT INTO `visit_logs` VALUES (173, 'device_jkl012', '2026-04-10 12:13:36', 42);
INSERT INTO `visit_logs` VALUES (174, 'device_bcd890', '2026-04-10 21:22:58', 472);
INSERT INTO `visit_logs` VALUES (175, 'device_bcd890', '2026-04-10 09:35:50', 47);
INSERT INTO `visit_logs` VALUES (176, 'device_efg111', '2026-04-10 08:54:24', 261);
INSERT INTO `visit_logs` VALUES (177, 'device_efg111', '2026-04-10 22:13:37', 250);
INSERT INTO `visit_logs` VALUES (178, 'device_bcd890', '2026-04-10 21:49:40', 110);
INSERT INTO `visit_logs` VALUES (179, 'device_ghi789', '2026-04-10 16:29:16', 3);
INSERT INTO `visit_logs` VALUES (180, 'device_def456', '2026-04-10 18:57:47', 50);
INSERT INTO `visit_logs` VALUES (181, 'device_pqr678', '2026-04-11 08:05:38', 6);
INSERT INTO `visit_logs` VALUES (182, 'device_stu901', '2026-04-11 11:57:51', 179);
INSERT INTO `visit_logs` VALUES (183, 'device_mno345', '2026-04-11 14:05:15', 133);
INSERT INTO `visit_logs` VALUES (184, 'device_pqr678', '2026-04-11 13:53:55', 115);
INSERT INTO `visit_logs` VALUES (185, 'device_pqr678', '2026-04-11 16:15:23', 456);
INSERT INTO `visit_logs` VALUES (186, 'device_def456', '2026-04-11 10:02:19', 3);
INSERT INTO `visit_logs` VALUES (187, 'device_stu901', '2026-04-11 19:46:24', 521);
INSERT INTO `visit_logs` VALUES (188, 'device_mno345', '2026-04-12 14:47:33', 18);
INSERT INTO `visit_logs` VALUES (189, 'device_bcd890', '2026-04-12 16:06:27', 31);
INSERT INTO `visit_logs` VALUES (190, 'device_pqr678', '2026-04-12 11:57:32', 4);
INSERT INTO `visit_logs` VALUES (191, 'device_bcd890', '2026-04-12 12:32:21', 258);
INSERT INTO `visit_logs` VALUES (192, 'device_pqr678', '2026-04-12 20:11:22', 19);
INSERT INTO `visit_logs` VALUES (193, 'device_efg111', '2026-04-12 15:16:11', 711);
INSERT INTO `visit_logs` VALUES (194, 'device_efg111', '2026-04-12 22:52:17', 172);
INSERT INTO `visit_logs` VALUES (195, 'device_stu901', '2026-04-12 16:10:45', 329);
INSERT INTO `visit_logs` VALUES (196, 'device_def456', '2026-04-12 10:03:41', 8);
INSERT INTO `visit_logs` VALUES (197, 'device_vwx234', '2026-04-12 11:40:33', 10);
INSERT INTO `visit_logs` VALUES (198, 'device_stu901', '2026-04-12 18:57:57', 517);
INSERT INTO `visit_logs` VALUES (199, 'device_bcd890', '2026-04-12 08:41:58', 20);
INSERT INTO `visit_logs` VALUES (200, 'device_pqr678', '2026-04-12 15:48:07', 785);
INSERT INTO `visit_logs` VALUES (201, 'device_yza567', '2026-04-13 13:23:32', 427);
INSERT INTO `visit_logs` VALUES (202, 'device_yza567', '2026-04-13 18:06:47', 61);
INSERT INTO `visit_logs` VALUES (203, 'device_bcd890', '2026-04-13 11:48:53', 21);
INSERT INTO `visit_logs` VALUES (204, 'device_efg111', '2026-04-13 12:08:31', 6);
INSERT INTO `visit_logs` VALUES (205, 'device_stu901', '2026-04-13 10:40:41', 358);
INSERT INTO `visit_logs` VALUES (206, 'device_yza567', '2026-04-13 20:15:43', 6);
INSERT INTO `visit_logs` VALUES (207, 'device_def456', '2026-04-13 15:03:30', 34);
INSERT INTO `visit_logs` VALUES (208, 'device_mno345', '2026-04-13 18:49:22', 682);
INSERT INTO `visit_logs` VALUES (209, 'device_hij222', '2026-04-13 08:12:18', 426);
INSERT INTO `visit_logs` VALUES (210, 'device_mno345', '2026-04-13 10:17:54', 360);
INSERT INTO `visit_logs` VALUES (211, 'device_hij222', '2026-04-13 09:51:15', 668);
INSERT INTO `visit_logs` VALUES (212, 'device_def456', '2026-04-14 12:46:57', 4);
INSERT INTO `visit_logs` VALUES (213, 'device_efg111', '2026-04-14 20:29:48', 66);
INSERT INTO `visit_logs` VALUES (214, 'device_ghi789', '2026-04-14 08:29:32', 109);
INSERT INTO `visit_logs` VALUES (215, 'device_ghi789', '2026-04-14 20:23:48', 513);
INSERT INTO `visit_logs` VALUES (216, 'device_bcd890', '2026-04-14 10:26:04', 5);
INSERT INTO `visit_logs` VALUES (217, 'device_efg111', '2026-04-14 12:20:47', 50);
INSERT INTO `visit_logs` VALUES (218, 'device_vwx234', '2026-04-14 21:05:29', 5);
INSERT INTO `visit_logs` VALUES (219, 'device_stu901', '2026-04-14 14:03:24', 8);
INSERT INTO `visit_logs` VALUES (220, 'device_mno345', '2026-04-14 10:45:58', 96);
INSERT INTO `visit_logs` VALUES (221, 'device_ghi789', '2026-04-14 22:31:19', 89);
INSERT INTO `visit_logs` VALUES (222, 'device_yza567', '2026-04-14 21:46:16', 16);
INSERT INTO `visit_logs` VALUES (223, 'device_efg111', '2026-04-14 09:04:34', 145);
INSERT INTO `visit_logs` VALUES (224, 'device_mno345', '2026-04-14 13:16:13', 418);
INSERT INTO `visit_logs` VALUES (225, 'device_hij222', '2026-04-14 20:15:21', 480);
INSERT INTO `visit_logs` VALUES (226, 'device_ghi789', '2026-04-15 17:19:57', 390);
INSERT INTO `visit_logs` VALUES (227, 'device_efg111', '2026-04-15 20:11:46', 381);
INSERT INTO `visit_logs` VALUES (228, 'device_efg111', '2026-04-15 19:09:30', 364);
INSERT INTO `visit_logs` VALUES (229, 'device_pqr678', '2026-04-15 11:09:21', 22);
INSERT INTO `visit_logs` VALUES (230, 'device_hij222', '2026-04-15 08:58:50', 83);
INSERT INTO `visit_logs` VALUES (231, 'device_vwx234', '2026-04-15 16:38:56', 33);
INSERT INTO `visit_logs` VALUES (232, 'device_pqr678', '2026-04-15 13:11:06', 707);
INSERT INTO `visit_logs` VALUES (233, 'device_jkl012', '2026-04-15 16:08:02', 530);
INSERT INTO `visit_logs` VALUES (234, 'device_yza567', '2026-04-15 14:47:49', 873);
INSERT INTO `visit_logs` VALUES (235, 'device_hij222', '2026-04-15 13:34:22', 293);
INSERT INTO `visit_logs` VALUES (236, 'device_ghi789', '2026-04-15 21:26:59', 43);
INSERT INTO `visit_logs` VALUES (237, 'device_jkl012', '2026-04-15 16:13:38', 150);
INSERT INTO `visit_logs` VALUES (238, 'device_ghi789', '2026-04-15 13:35:49', 3);
INSERT INTO `visit_logs` VALUES (239, 'device_efg111', '2026-04-15 20:45:03', 34);
INSERT INTO `visit_logs` VALUES (240, 'device_yza567', '2026-04-15 17:28:09', 403);
INSERT INTO `visit_logs` VALUES (241, 'device_hij222', '2026-04-16 08:06:14', 77);
INSERT INTO `visit_logs` VALUES (242, 'device_pqr678', '2026-04-16 21:27:30', 85);
INSERT INTO `visit_logs` VALUES (243, 'device_abc123', '2026-04-16 10:54:48', 34);
INSERT INTO `visit_logs` VALUES (244, 'device_pqr678', '2026-04-16 22:10:40', 305);
INSERT INTO `visit_logs` VALUES (245, 'device_yza567', '2026-04-16 15:10:47', 720);
INSERT INTO `visit_logs` VALUES (246, 'device_vwx234', '2026-04-16 21:01:59', 299);
INSERT INTO `visit_logs` VALUES (247, 'device_efg111', '2026-04-16 19:01:06', 218);
INSERT INTO `visit_logs` VALUES (248, 'device_abc123', '2026-04-16 17:42:53', 453);
INSERT INTO `visit_logs` VALUES (249, 'device_ghi789', '2026-04-16 18:25:27', 7);
INSERT INTO `visit_logs` VALUES (250, 'device_hij222', '2026-04-16 11:14:24', 44);
INSERT INTO `visit_logs` VALUES (251, 'device_abc123', '2026-04-16 14:06:54', 6);
INSERT INTO `visit_logs` VALUES (252, 'device_mno345', '2026-04-17 18:59:58', 279);
INSERT INTO `visit_logs` VALUES (253, 'device_bcd890', '2026-04-17 10:46:27', 5);
INSERT INTO `visit_logs` VALUES (254, 'device_ghi789', '2026-04-17 15:04:06', 882);
INSERT INTO `visit_logs` VALUES (255, 'device_jkl012', '2026-04-17 15:09:45', 413);
INSERT INTO `visit_logs` VALUES (256, 'device_abc123', '2026-04-17 19:30:40', 46);
INSERT INTO `visit_logs` VALUES (257, 'device_bcd890', '2026-04-17 11:20:16', 9);
INSERT INTO `visit_logs` VALUES (258, 'device_mno345', '2026-04-17 08:09:57', 223);
INSERT INTO `visit_logs` VALUES (259, 'device_efg111', '2026-04-17 14:48:54', 727);
INSERT INTO `visit_logs` VALUES (260, 'device_hij222', '2026-04-17 08:58:15', 713);
INSERT INTO `visit_logs` VALUES (261, 'device_pqr678', '2026-04-17 15:39:48', 18);
INSERT INTO `visit_logs` VALUES (262, 'device_pqr678', '2026-04-17 16:00:02', 405);
INSERT INTO `visit_logs` VALUES (263, 'device_def456', '2026-04-17 13:11:15', 54);
INSERT INTO `visit_logs` VALUES (264, 'device_yza567', '2026-04-17 22:31:26', 871);
INSERT INTO `visit_logs` VALUES (265, 'device_vwx234', '2026-04-17 22:59:23', 102);
INSERT INTO `visit_logs` VALUES (266, 'device_stu901', '2026-04-17 10:08:39', 284);
INSERT INTO `visit_logs` VALUES (267, 'device_stu901', '2026-04-18 21:19:33', 115);
INSERT INTO `visit_logs` VALUES (268, 'device_jkl012', '2026-04-18 22:39:46', 198);
INSERT INTO `visit_logs` VALUES (269, 'device_hij222', '2026-04-18 15:03:54', 491);
INSERT INTO `visit_logs` VALUES (270, 'device_mno345', '2026-04-18 18:31:06', 93);
INSERT INTO `visit_logs` VALUES (271, 'device_def456', '2026-04-18 12:57:22', 547);
INSERT INTO `visit_logs` VALUES (272, 'device_vwx234', '2026-04-18 16:25:03', 33);
INSERT INTO `visit_logs` VALUES (273, 'device_vwx234', '2026-04-18 19:10:17', 163);
INSERT INTO `visit_logs` VALUES (274, 'device_mno345', '2026-04-18 12:39:46', 550);
INSERT INTO `visit_logs` VALUES (275, 'device_efg111', '2026-04-18 08:12:17', 77);
INSERT INTO `visit_logs` VALUES (276, 'device_jkl012', '2026-04-18 21:05:10', 28);
INSERT INTO `visit_logs` VALUES (277, 'device_jkl012', '2026-04-18 11:16:08', 44);
INSERT INTO `visit_logs` VALUES (278, 'device_yza567', '2026-04-18 14:03:55', 579);
INSERT INTO `visit_logs` VALUES (279, 'device_abc123', '2026-04-18 14:03:25', 116);
INSERT INTO `visit_logs` VALUES (280, 'device_jkl012', '2026-04-19 08:27:45', 213);
INSERT INTO `visit_logs` VALUES (281, 'device_hij222', '2026-04-19 15:17:31', 4);
INSERT INTO `visit_logs` VALUES (282, 'device_stu901', '2026-04-19 15:02:37', 285);
INSERT INTO `visit_logs` VALUES (283, 'device_bcd890', '2026-04-19 10:56:21', 8);
INSERT INTO `visit_logs` VALUES (284, 'device_bcd890', '2026-04-19 14:03:30', 5);
INSERT INTO `visit_logs` VALUES (285, 'device_jkl012', '2026-04-19 10:26:20', 703);
INSERT INTO `visit_logs` VALUES (286, 'device_vwx234', '2026-04-19 12:03:06', 141);
INSERT INTO `visit_logs` VALUES (287, 'device_efg111', '2026-04-19 11:42:42', 653);
INSERT INTO `visit_logs` VALUES (288, 'device_ghi789', '2026-04-19 13:12:01', 66);
INSERT INTO `visit_logs` VALUES (289, 'device_ghi789', '2026-04-19 09:00:43', 8);
INSERT INTO `visit_logs` VALUES (290, 'device_abc123', '2026-04-19 20:00:25', 624);
INSERT INTO `visit_logs` VALUES (291, 'device_ghi789', '2026-04-20 10:19:32', 290);
INSERT INTO `visit_logs` VALUES (292, 'device_stu901', '2026-04-20 16:49:33', 186);
INSERT INTO `visit_logs` VALUES (293, 'device_def456', '2026-04-20 12:25:43', 19);
INSERT INTO `visit_logs` VALUES (294, 'device_efg111', '2026-04-20 13:45:51', 25);
INSERT INTO `visit_logs` VALUES (295, 'device_hij222', '2026-04-20 12:13:11', 204);
INSERT INTO `visit_logs` VALUES (296, 'device_pqr678', '2026-04-20 12:54:20', 60);
INSERT INTO `visit_logs` VALUES (297, 'device_efg111', '2026-04-20 19:54:51', 168);
INSERT INTO `visit_logs` VALUES (298, 'device_bcd890', '2026-04-20 09:12:10', 709);
INSERT INTO `visit_logs` VALUES (299, 'device_jkl012', '2026-04-20 09:29:55', 836);
INSERT INTO `visit_logs` VALUES (300, 'device_def456', '2026-04-20 18:24:02', 477);
INSERT INTO `visit_logs` VALUES (301, 'device_def456', '2026-04-20 16:10:32', 6);
INSERT INTO `visit_logs` VALUES (302, 'device_abc123', '2026-04-20 19:18:07', 565);
INSERT INTO `visit_logs` VALUES (303, 'device_pqr678', '2026-04-20 10:53:03', 189);
INSERT INTO `visit_logs` VALUES (304, 'device_abc123', '2026-04-20 09:14:32', 345);
INSERT INTO `visit_logs` VALUES (305, 'device_def456', '2026-04-20 10:48:56', 879);
INSERT INTO `visit_logs` VALUES (306, 'device_bcd890', '2026-04-20 20:50:11', 268);
INSERT INTO `visit_logs` VALUES (307, 'device_def456', '2026-04-21 08:58:12', 55);
INSERT INTO `visit_logs` VALUES (308, 'device_bcd890', '2026-04-21 20:09:33', 58);
INSERT INTO `visit_logs` VALUES (309, 'device_efg111', '2026-04-21 16:15:01', 8);
INSERT INTO `visit_logs` VALUES (310, 'device_jkl012', '2026-04-21 10:00:50', 531);
INSERT INTO `visit_logs` VALUES (311, 'device_yza567', '2026-04-21 22:17:55', 32);
INSERT INTO `visit_logs` VALUES (312, 'device_pqr678', '2026-04-21 12:54:33', 377);
INSERT INTO `visit_logs` VALUES (313, 'device_abc123', '2026-04-21 19:33:21', 572);
INSERT INTO `visit_logs` VALUES (314, 'device_efg111', '2026-04-21 12:42:29', 133);
INSERT INTO `visit_logs` VALUES (315, 'device_stu901', '2026-04-21 13:37:22', 152);
INSERT INTO `visit_logs` VALUES (316, 'device_bcd890', '2026-04-21 13:02:31', 472);
INSERT INTO `visit_logs` VALUES (317, 'device_def456', '2026-04-21 18:01:51', 32);
INSERT INTO `visit_logs` VALUES (318, 'device_u9tzb0mphoq', '2026-05-04 18:04:28', 1);
INSERT INTO `visit_logs` VALUES (319, 'device_u9tzb0mphoq', '2026-05-04 18:04:29', 1);
INSERT INTO `visit_logs` VALUES (320, 'device_u9tzb0mphoq', '2026-05-04 18:04:57', 2);
INSERT INTO `visit_logs` VALUES (321, 'device_u9tzb0mphoq', '2026-05-05 18:42:11', 16);
INSERT INTO `visit_logs` VALUES (322, 'device_u9tzb0mphoq', '2026-05-05 18:42:44', 1);
INSERT INTO `visit_logs` VALUES (323, 'device_u9tzb0mphoq', '2026-05-05 18:42:59', 13);
INSERT INTO `visit_logs` VALUES (324, 'device_u9tzb0mphoq', '2026-05-05 18:43:57', 35);
INSERT INTO `visit_logs` VALUES (325, 'wangwu', '2026-05-08 12:25:20', 47);
INSERT INTO `visit_logs` VALUES (326, 'wangwu', '2026-05-08 12:25:40', 12);
INSERT INTO `visit_logs` VALUES (327, 'wangwu', '2026-05-08 13:40:03', 2);
INSERT INTO `visit_logs` VALUES (328, 'device_u9tzb0mphoq', '2026-05-08 16:12:17', 52);
INSERT INTO `visit_logs` VALUES (329, 'zhangsan', '2026-05-08 16:12:33', 17);
INSERT INTO `visit_logs` VALUES (330, 'zhangsan', '2026-05-08 16:13:08', 19);
INSERT INTO `visit_logs` VALUES (331, 'zhangsan', '2026-05-08 16:13:19', 2);
INSERT INTO `visit_logs` VALUES (332, 'zhangsan', '2026-05-08 16:13:30', 4);
INSERT INTO `visit_logs` VALUES (333, 'wangwu', '2026-05-08 16:25:01', 11);
INSERT INTO `visit_logs` VALUES (334, 'wangwu', '2026-05-08 16:27:38', 1);
INSERT INTO `visit_logs` VALUES (335, 'wangwu', '2026-05-08 16:36:51', 1);
INSERT INTO `visit_logs` VALUES (336, 'wangwu', '2026-05-08 16:37:19', 1);
INSERT INTO `visit_logs` VALUES (337, 'wangwu', '2026-05-08 16:39:22', 1);
INSERT INTO `visit_logs` VALUES (338, 'wangwu', '2026-05-08 16:39:23', 1);
INSERT INTO `visit_logs` VALUES (339, 'wangwu', '2026-05-08 16:39:24', 1);
INSERT INTO `visit_logs` VALUES (340, 'device_wfwwnfxmbs', '2026-05-08 16:40:21', 3);
INSERT INTO `visit_logs` VALUES (341, 'wangwu', '2026-05-08 16:50:46', 13);
INSERT INTO `visit_logs` VALUES (342, 'zhangsan', '2026-05-08 16:51:15', 29);
INSERT INTO `visit_logs` VALUES (343, 'zhangsan', '2026-05-08 16:54:29', 1);
INSERT INTO `visit_logs` VALUES (344, 'zhangsan', '2026-05-08 16:56:50', 1);
INSERT INTO `visit_logs` VALUES (345, 'zhangsan', '2026-05-08 16:56:53', 2);
INSERT INTO `visit_logs` VALUES (346, 'zhangsan', '2026-05-08 16:56:54', 2);
INSERT INTO `visit_logs` VALUES (347, 'zhangsan', '2026-05-08 16:56:58', 3);
INSERT INTO `visit_logs` VALUES (348, 'zhangsan', '2026-05-08 16:57:02', 4);
INSERT INTO `visit_logs` VALUES (349, 'zhangsan', '2026-05-08 16:57:10', 2);
INSERT INTO `visit_logs` VALUES (350, 'zhangsan', '2026-05-08 16:57:12', 1);
INSERT INTO `visit_logs` VALUES (351, 'zhangsan', '2026-05-08 17:22:28', 1);
INSERT INTO `visit_logs` VALUES (352, 'zhangsan', '2026-05-08 17:22:52', 1);
INSERT INTO `visit_logs` VALUES (353, 'zhangsan', '2026-05-08 17:23:00', 7);
INSERT INTO `visit_logs` VALUES (354, 'zhangsan', '2026-05-08 17:23:51', 17);
INSERT INTO `visit_logs` VALUES (355, 'zhangsan', '2026-05-08 17:24:37', 41);
INSERT INTO `visit_logs` VALUES (356, 'zhangsan', '2026-05-08 17:26:09', 119);
INSERT INTO `visit_logs` VALUES (357, 'zhangsan', '2026-05-08 17:26:38', 2);
INSERT INTO `visit_logs` VALUES (358, 'zhangsan', '2026-05-08 17:30:08', 134);
INSERT INTO `visit_logs` VALUES (359, 'zhangsan', '2026-05-08 17:30:12', 1);
INSERT INTO `visit_logs` VALUES (360, 'zhangsan', '2026-05-08 17:33:48', 233);
INSERT INTO `visit_logs` VALUES (361, 'zhangsan', '2026-05-08 17:41:22', 21);
INSERT INTO `visit_logs` VALUES (362, 'zhangsan', '2026-05-08 17:41:34', 5);
INSERT INTO `visit_logs` VALUES (363, 'zhangsan', '2026-05-08 17:42:54', 3);
INSERT INTO `visit_logs` VALUES (364, 'zhangsan', '2026-05-08 17:44:24', 189);
INSERT INTO `visit_logs` VALUES (365, 'zhangsan', '2026-05-08 17:47:17', 173);
INSERT INTO `visit_logs` VALUES (366, 'zhangsan', '2026-05-08 17:54:56', 458);
INSERT INTO `visit_logs` VALUES (367, 'zhangsan', '2026-05-08 18:01:10', 1);
INSERT INTO `visit_logs` VALUES (368, 'zhangsan', '2026-05-08 18:03:37', 2);
INSERT INTO `visit_logs` VALUES (369, 'zhangsan', '2026-05-08 18:08:03', 206);
INSERT INTO `visit_logs` VALUES (370, 'zhangsan', '2026-05-08 18:10:39', 20);
INSERT INTO `visit_logs` VALUES (371, 'zhangsan', '2026-05-08 18:14:49', 235);
INSERT INTO `visit_logs` VALUES (372, 'zhangsan', '2026-05-08 18:15:32', 14);
INSERT INTO `visit_logs` VALUES (373, 'zhangsan', '2026-05-08 18:19:42', 285);
INSERT INTO `visit_logs` VALUES (374, 'zhangsan', '2026-05-08 18:23:07', 3);
INSERT INTO `visit_logs` VALUES (375, 'zhangsan', '2026-05-08 18:24:16', 2);
INSERT INTO `visit_logs` VALUES (376, 'zhangsan', '2026-05-08 18:24:29', 13);
INSERT INTO `visit_logs` VALUES (377, 'zhangsan', '2026-05-08 18:26:50', 13);
INSERT INTO `visit_logs` VALUES (378, 'zhangsan', '2026-05-08 18:31:46', 724);
INSERT INTO `visit_logs` VALUES (379, 'zhangsan', '2026-05-08 18:32:23', 1);
INSERT INTO `visit_logs` VALUES (380, 'zhangsan', '2026-05-08 18:36:08', 254);
INSERT INTO `visit_logs` VALUES (381, 'zhangsan', '2026-05-08 18:40:42', 18);
INSERT INTO `visit_logs` VALUES (382, 'zhangsan', '2026-05-08 18:41:31', 322);
INSERT INTO `visit_logs` VALUES (383, 'zhangsan', '2026-05-08 18:46:05', 1);
INSERT INTO `visit_logs` VALUES (384, 'zhangsan', '2026-05-08 18:48:16', 6);
INSERT INTO `visit_logs` VALUES (385, 'zhangsan', '2026-05-08 18:48:49', 7);
INSERT INTO `visit_logs` VALUES (386, 'zhangsan', '2026-05-08 18:48:54', 1);
INSERT INTO `visit_logs` VALUES (387, 'zhangsan', '2026-05-08 18:49:59', 1);
INSERT INTO `visit_logs` VALUES (388, 'zhangsan', '2026-05-08 18:51:52', 88);
INSERT INTO `visit_logs` VALUES (389, 'zhangsan', '2026-05-08 18:52:30', 125);
INSERT INTO `visit_logs` VALUES (390, 'zhangsan', '2026-05-08 19:00:26', 12);
INSERT INTO `visit_logs` VALUES (391, 'zhangsan', '2026-05-08 19:01:18', 4);
INSERT INTO `visit_logs` VALUES (392, 'zhangsan', '2026-05-08 19:01:32', 10);
INSERT INTO `visit_logs` VALUES (393, 'zhangsan', '2026-05-08 19:01:42', 5);
INSERT INTO `visit_logs` VALUES (394, 'zhangsan', '2026-05-08 19:01:46', 1);
INSERT INTO `visit_logs` VALUES (395, 'zhangsan', '2026-05-08 19:01:50', 1);
INSERT INTO `visit_logs` VALUES (396, 'zhangsan', '2026-05-08 19:03:06', 5);
INSERT INTO `visit_logs` VALUES (397, 'zhangsan', '2026-05-08 19:04:03', 692);
INSERT INTO `visit_logs` VALUES (398, 'zhangsan', '2026-05-08 19:05:22', 64);
INSERT INTO `visit_logs` VALUES (399, 'zhangsan', '2026-05-08 19:05:58', 2);
INSERT INTO `visit_logs` VALUES (400, 'zhangsan', '2026-05-08 19:06:20', 9);
INSERT INTO `visit_logs` VALUES (401, 'zhangsan', '2026-05-08 19:06:36', 3);
INSERT INTO `visit_logs` VALUES (402, 'zhangsan', '2026-05-08 19:07:39', 4);
INSERT INTO `visit_logs` VALUES (403, 'zhangsan', '2026-05-08 19:08:43', 3);
INSERT INTO `visit_logs` VALUES (404, 'zhangsan', '2026-05-08 19:09:31', 5);
INSERT INTO `visit_logs` VALUES (405, 'zhangsan', '2026-05-08 19:09:41', 1);
INSERT INTO `visit_logs` VALUES (406, 'zhangsan', '2026-05-08 19:09:46', 1);
INSERT INTO `visit_logs` VALUES (407, 'zhangsan', '2026-05-08 19:11:52', 12);
INSERT INTO `visit_logs` VALUES (408, 'zhangsan', '2026-05-08 19:12:05', 1);
INSERT INTO `visit_logs` VALUES (409, 'zhangsan', '2026-05-08 19:12:24', 2);
INSERT INTO `visit_logs` VALUES (410, 'zhangsan', '2026-05-08 19:14:15', 611);
INSERT INTO `visit_logs` VALUES (411, 'zhangsan', '2026-05-08 19:14:22', 5);
INSERT INTO `visit_logs` VALUES (412, 'zhangsan', '2026-05-08 19:17:52', 12);
INSERT INTO `visit_logs` VALUES (413, 'zhangsan', '2026-05-08 19:18:02', 6);
INSERT INTO `visit_logs` VALUES (414, 'zhangsan', '2026-05-08 19:18:06', 1);
INSERT INTO `visit_logs` VALUES (415, 'zhangsan', '2026-05-08 19:19:17', 1);
INSERT INTO `visit_logs` VALUES (416, 'zhangsan', '2026-05-08 19:19:26', 9);
INSERT INTO `visit_logs` VALUES (417, 'zhangsan', '2026-05-08 19:19:38', 7);
INSERT INTO `visit_logs` VALUES (418, 'zhangsan', '2026-05-08 19:24:35', 600);
INSERT INTO `visit_logs` VALUES (419, 'zhangsan', '2026-05-08 19:27:47', 190);
INSERT INTO `visit_logs` VALUES (420, 'zhangsan', '2026-05-08 19:28:01', 14);
INSERT INTO `visit_logs` VALUES (421, 'zhangsan', '2026-05-08 19:28:02', 14);
INSERT INTO `visit_logs` VALUES (422, 'zhangsan', '2026-05-08 19:28:14', 12);
INSERT INTO `visit_logs` VALUES (423, 'zhangsan', '2026-05-08 19:28:14', 12);
INSERT INTO `visit_logs` VALUES (424, 'zhangsan', '2026-05-08 19:33:08', 294);
INSERT INTO `visit_logs` VALUES (425, 'zhangsan', '2026-05-08 19:33:43', 5);
INSERT INTO `visit_logs` VALUES (426, 'zhangsan', '2026-05-08 19:33:46', 1);
INSERT INTO `visit_logs` VALUES (427, 'zhangsan', '2026-05-08 19:33:57', 11);
INSERT INTO `visit_logs` VALUES (428, 'zhangsan', '2026-05-08 19:34:09', 6);
INSERT INTO `visit_logs` VALUES (429, 'zhangsan', '2026-05-08 19:35:17', 2);
INSERT INTO `visit_logs` VALUES (430, 'zhangsan', '2026-05-08 19:36:19', 9);
INSERT INTO `visit_logs` VALUES (431, 'zhangsan', '2026-05-08 19:36:40', 16);
INSERT INTO `visit_logs` VALUES (432, 'zhangsan', '2026-05-08 19:37:05', 11);
INSERT INTO `visit_logs` VALUES (433, 'zhangsan', '2026-05-08 19:38:24', 7);
INSERT INTO `visit_logs` VALUES (434, 'zhangsan', '2026-05-08 19:40:30', 11);
INSERT INTO `visit_logs` VALUES (435, 'zhangsan', '2026-05-09 14:15:32', 2);
INSERT INTO `visit_logs` VALUES (436, 'zhangsan', '2026-05-09 14:16:45', 57);
INSERT INTO `visit_logs` VALUES (437, 'zhangsan', '2026-05-09 14:16:48', 2);
INSERT INTO `visit_logs` VALUES (438, 'lisi', '2026-05-09 14:16:57', 9);
INSERT INTO `visit_logs` VALUES (439, 'lisi', '2026-05-09 14:17:12', 15);
INSERT INTO `visit_logs` VALUES (440, 'lisi', '2026-05-09 14:17:27', 10);
INSERT INTO `visit_logs` VALUES (441, 'lisi', '2026-05-09 14:17:35', 2);
INSERT INTO `visit_logs` VALUES (442, 'lisi', '2026-05-09 14:17:40', 2);
INSERT INTO `visit_logs` VALUES (443, 'lisi', '2026-05-09 14:18:50', 65);
INSERT INTO `visit_logs` VALUES (444, 'lisi', '2026-05-09 14:18:53', 2);
INSERT INTO `visit_logs` VALUES (445, 'lisi', '2026-05-09 14:24:59', 303);
INSERT INTO `visit_logs` VALUES (446, 'lisi', '2026-05-09 14:25:32', 7);
INSERT INTO `visit_logs` VALUES (447, 'lisi', '2026-05-09 14:25:58', 2);
INSERT INTO `visit_logs` VALUES (448, 'lisi', '2026-05-09 19:29:27', 279);
INSERT INTO `visit_logs` VALUES (449, 'lisi', '2026-05-09 19:32:49', 62);
INSERT INTO `visit_logs` VALUES (450, 'lisi', '2026-05-09 19:33:54', 1);
INSERT INTO `visit_logs` VALUES (451, 'lisi', '2026-05-09 19:36:43', 34);
INSERT INTO `visit_logs` VALUES (452, 'lisi', '2026-05-09 19:44:18', 1);
INSERT INTO `visit_logs` VALUES (453, 'lisi', '2026-05-09 23:49:36', 2);
INSERT INTO `visit_logs` VALUES (454, 'lisi', '2026-05-09 23:58:40', 6);
INSERT INTO `visit_logs` VALUES (455, 'lisi', '2026-05-09 23:58:42', 2);
INSERT INTO `visit_logs` VALUES (456, 'lisi', '2026-05-09 23:58:47', 1);
INSERT INTO `visit_logs` VALUES (457, 'lisi', '2026-05-09 23:58:54', 7);
INSERT INTO `visit_logs` VALUES (458, 'lisi', '2026-05-09 23:59:05', 6);
INSERT INTO `visit_logs` VALUES (459, 'lisi', '2026-05-10 00:01:47', 4);
INSERT INTO `visit_logs` VALUES (460, 'lisi', '2026-05-10 00:02:02', 15);
INSERT INTO `visit_logs` VALUES (461, 'lisi', '2026-05-10 00:02:56', 44);
INSERT INTO `visit_logs` VALUES (462, 'lisi', '2026-05-10 00:03:03', 2);
INSERT INTO `visit_logs` VALUES (463, 'lisi', '2026-05-10 00:03:17', 7);
INSERT INTO `visit_logs` VALUES (464, 'lisi', '2026-05-10 00:03:22', 2);
INSERT INTO `visit_logs` VALUES (465, 'lisi', '2026-05-10 00:03:39', 8);
INSERT INTO `visit_logs` VALUES (466, 'lisi', '2026-05-10 00:03:47', 4);
INSERT INTO `visit_logs` VALUES (467, 'lisi', '2026-05-10 00:04:06', 15);
INSERT INTO `visit_logs` VALUES (468, 'lisi', '2026-05-10 00:04:08', 3);
INSERT INTO `visit_logs` VALUES (469, 'lisi', '2026-05-10 00:04:18', 6);
INSERT INTO `visit_logs` VALUES (470, 'lisi', '2026-05-10 00:04:54', 36);
INSERT INTO `visit_logs` VALUES (471, 'lisi', '2026-05-10 00:05:17', 18);
INSERT INTO `visit_logs` VALUES (472, 'lisi', '2026-05-10 00:05:28', 8);
INSERT INTO `visit_logs` VALUES (473, 'lisi', '2026-05-10 00:05:36', 4);
INSERT INTO `visit_logs` VALUES (474, 'lisi', '2026-05-10 00:05:39', 1);
INSERT INTO `visit_logs` VALUES (475, 'lisi', '2026-05-10 00:05:47', 7);
INSERT INTO `visit_logs` VALUES (476, 'lisi', '2026-05-10 00:05:51', 1);
INSERT INTO `visit_logs` VALUES (477, 'lisi', '2026-05-10 00:05:59', 1);
INSERT INTO `visit_logs` VALUES (478, 'lisi', '2026-05-10 00:06:42', 37);
INSERT INTO `visit_logs` VALUES (479, 'lisi', '2026-05-10 00:06:56', 6);
INSERT INTO `visit_logs` VALUES (480, 'lisi', '2026-05-10 00:07:47', 52);
INSERT INTO `visit_logs` VALUES (481, 'lisi', '2026-05-10 00:07:57', 6);
INSERT INTO `visit_logs` VALUES (482, 'lisi', '2026-05-10 00:08:46', 12);
INSERT INTO `visit_logs` VALUES (483, 'lisi', '2026-05-10 00:08:51', 1);
INSERT INTO `visit_logs` VALUES (484, 'lisi', '2026-05-10 00:09:06', 15);
INSERT INTO `visit_logs` VALUES (485, 'lisi', '2026-05-10 01:11:55', 6);
INSERT INTO `visit_logs` VALUES (486, 'lisi', '2026-05-10 01:18:11', 25);
INSERT INTO `visit_logs` VALUES (487, 'lisi', '2026-05-10 01:18:20', 2);
INSERT INTO `visit_logs` VALUES (488, 'lisi', '2026-05-10 01:22:28', 11);
INSERT INTO `visit_logs` VALUES (489, 'lisi', '2026-05-10 10:13:10', 38);
INSERT INTO `visit_logs` VALUES (490, 'lisi', '2026-05-10 10:14:33', 61);
INSERT INTO `visit_logs` VALUES (491, 'lisi', '2026-05-10 10:14:49', 6);
INSERT INTO `visit_logs` VALUES (492, 'lisi', '2026-05-10 10:14:59', 1);
INSERT INTO `visit_logs` VALUES (493, 'lisi', '2026-05-10 10:15:05', 1);
INSERT INTO `visit_logs` VALUES (494, 'lisi', '2026-05-10 10:16:02', 36);
INSERT INTO `visit_logs` VALUES (495, 'lisi', '2026-05-10 10:16:19', 10);

SET FOREIGN_KEY_CHECKS = 1;
