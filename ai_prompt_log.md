1) Prompt (Cardinality cơ bản)
"Giải thích Cardinality trong MySQL: nó là gì, MySQL dùng nó như thế nào khi chọn index, và vì sao cột có 2-3 giá trị lại là ứng viên tồi để tạo B-Tree index?"

Tóm tắt trả lời:
- Cardinality = số giá trị khác nhau trong cột.
- Optimizer dùng cardinality để ước lượng selectivity; index có cardinality cao (nhiều giá trị khác nhau) hữu ích.
- Cột boolean/low-cardinality thường không giúp vì selectivity thấp; full table scan đôi khi rẻ hơn.

2) Prompt (Index trên TEXT và ảnh hưởng tới storage)
"Nếu tôi tạo B-Tree index prefix trên cột TEXT (content(255)), điều này ảnh hưởng thế nào tới disk và RAM? Có lựa chọn nào tốt hơn cho tìm kiếm văn bản?"

Tóm tắt trả lời:
- B-Tree prefix lưu phần prefix của mỗi row trong index, làm tăng index size lớn; nhiều I/O và RAM để cache index.
- Với TEXT, nên dùng FULLTEXT index (InnoDB/ MyISAM) hoặc external search (Elasticsearch) cho tìm kiếm full-text.

3) Prompt (Tác động lên INSERT)
"Khi bảng có N secondary indexes, mỗi INSERT phải làm gì với các B-Tree? Giải thích ngắn về số cập nhật B-Tree per INSERT trong InnoDB."

Tóm tắt trả lời:
- Mỗi INSERT: chèn vào clustered index (PRIMARY) và chèn vào mỗi secondary index (secondary leaf lưu primary key).
- Vì vậy số thao tác B-Tree ≈ 1 + number_of_secondary_indexes; xóa index giảm số thao tác này tương ứng.
