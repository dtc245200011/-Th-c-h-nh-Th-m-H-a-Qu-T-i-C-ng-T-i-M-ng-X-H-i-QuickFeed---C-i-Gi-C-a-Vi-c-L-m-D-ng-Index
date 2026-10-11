Tiêu đề: Báo cáo tối ưu chỉ mục cho QuickFeed (tóm tắt)

Tóm tắt (200 từ):  
Sau khi kiểm tra, bảng Posts ban đầu có 5 index: PRIMARY(post_id), idx_user_id, idx_content (prefix 255), idx_post_type, idx_is_visible, idx_created_at. Ba index idx_content, idx_post_type, idx_is_visible được xác định là gây lãng phí tài nguyên: idx_content (TEXT prefix) tạo ra cây B‑Tree rất lớn vì lưu nhiều bytes của nội dung; idx_post_type có chỉ 3 giá trị (cardinality thấp); idx_is_visible chỉ có 2 giá trị. Mỗi thao tác INSERT trên InnoDB phải cập nhật một node trong cây B‑Tree cho mỗi index phụ (secondary index) cộng với cập nhật clustered index (PRIMARY). Do đó, với 5 index (1 PK + 4 secondary), mỗi INSERT gây 4 cập nhật secondary; sau khi xóa 3 index vô dụng, số cập nhật secondary giảm từ 4 xuống còn 1 (chỉ idx_user_id hoặc idx_created_at tùy cấu hình), tức là bớt 3 cập nhật B‑Tree cho mỗi INSERT. Kết quả mong đợi: giảm độ trễ ghi (INSERT) rõ rệt, giảm I/O và contention, và giải phóng dung lượng đĩa tương ứng với INDEX_LENGTH đã giảm.

Sự đánh đổi Read vs Write:

Giữ index giúp truy vấn đọc (SELECT có điều kiện) nhanh hơn nhưng tăng chi phí ghi (INSERT/UPDATE/DELETE) vì phải duy trì nhiều B‑Tree.

Xóa index vô dụng giảm I/O ghi, giảm kích thước lưu trữ, và cải thiện throughput ghi; đổi lại, một vài truy vấn đọc rất hiếm có thể chậm hơn — nhưng với các cột có cardinality thấp, optimizer thường bỏ qua index nên không mất lợi ích thực tế.

Gợi ý: với cột content cần tìm kiếm từ khóa, dùng FULLTEXT (hoặc external search engine) thay vì B‑Tree prefix để tiết kiệm không gian và có hiệu năng tìm kiếm văn bản tốt hơn.

Kết luận ngắn: Xóa idx_content, idx_post_type, idx_is_visible sẽ loại bỏ 3 cập nhật B‑Tree cho mỗi INSERT và giảm đáng kể INDEX_LENGTH. Sau dọn dẹp, chạy SHOW TABLE STATUS hoặc truy vấn information_schema.TABLES để chứng minh giảm index_mb.
