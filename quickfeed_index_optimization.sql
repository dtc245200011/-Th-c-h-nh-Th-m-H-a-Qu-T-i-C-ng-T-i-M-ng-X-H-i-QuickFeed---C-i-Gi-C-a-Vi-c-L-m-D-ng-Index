-- quickfeed_index_optimization.sql
-- Mục tiêu: đo kích thước Data/Index, xóa các index vô dụng, đo lại để so sánh.

-- 0) Chạy trong MySQL client (đảm bảo đang dùng user có quyền ALTER)
USE quickfeed_db;

-- 1) Kiểm tra trạng thái bảng Posts (SHOW TABLE STATUS)
SHOW TABLE STATUS LIKE 'Posts';

-- 2) Truy vấn thông tin Data/Index bằng information_schema (kết quả tính theo MB)
SELECT
  TABLE_SCHEMA,
  TABLE_NAME,
  ROUND(DATA_LENGTH/1024/1024, 3) AS data_mb,
  ROUND(INDEX_LENGTH/1024/1024, 3) AS index_mb,
  ROUND((DATA_LENGTH+INDEX_LENGTH)/1024/1024, 3) AS total_mb,
  TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'quickfeed_db' AND TABLE_NAME = 'Posts';

-- 3) Liệt kê các index hiện có (dùng SHOW INDEX)
SHOW INDEX FROM Posts;

-- 4) ***PHẦN DỌN DẸP***: DROP các index đã phân tích là vô dụng
-- (Chỉ xóa 3 index đã xác định: idx_content, idx_post_type, idx_is_visible)
ALTER TABLE Posts DROP INDEX idx_content;
ALTER TABLE Posts DROP INDEX idx_post_type;
ALTER TABLE Posts DROP INDEX idx_is_visible;

-- 5) (Tùy chọn) Nếu bạn muốn thay thế idx_content bằng cơ chế tìm kiếm phù hợp:
-- CREATE FULLTEXT INDEX ft_content ON Posts(content);
-- Lưu ý: chỉ tạo FULLTEXT khi storage engine và phiên bản MySQL hỗ trợ và khi bạn cần tìm kiếm văn bản.

-- 6) Đo lại kích thước sau khi DROP INDEX
SHOW TABLE STATUS LIKE 'Posts';

SELECT
  TABLE_SCHEMA,
  TABLE_NAME,
  ROUND(DATA_LENGTH/1024/1024, 3) AS data_mb,
  ROUND(INDEX_LENGTH/1024/1024, 3) AS index_mb,
  ROUND((DATA_LENGTH+INDEX_LENGTH)/1024/1024, 3) AS total_mb,
  TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'quickfeed_db' AND TABLE_NAME = 'Posts';

-- 7) Kiểm tra index còn lại
SHOW INDEX FROM Posts;
