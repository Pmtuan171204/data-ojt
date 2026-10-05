# Thiết kế dữ liệu combo

Mỗi khung có các combo được phép chọn; mỗi combo gồm nhiều môn. Lựa chọn combo của sinh viên được lưu riêng với thông tin sinh viên. Phân biệt nhóm lựa chọn thể chất, chuyên ngành và các nhóm khác khi có quy định nguồn; chưa mặc định mỗi sinh viên chỉ được chọn một combo trên toàn chương trình.

## Tổ chức file

- `curriculum/IS/combo/<curriculum_code>/combos.csv`: danh sách combo của một khung.
- `curriculum/IS/combo/<curriculum_code>/combo_courses.csv`: môn thuộc các combo của khung đó.
- `curriculum/IS/combo/<curriculum_code>/combo_slot_mapping.csv`: ánh xạ môn combo vào các học phần lựa chọn trong khung, chỉ điền khi xác nhận được.
- `student/student_combos.csv`: lựa chọn combo của từng sinh viên, tạo sau khi thống nhất quy tắc chọn.

## combos.csv

| Cột | Ý nghĩa |
|---|---|
| curriculum_code | Mã khung cho phép combo này. |
| combo_id | ID combo nguyên bản trên trang trường, lưu như chuỗi định danh. |
| combo_name | Tên đầy đủ theo nguồn. |
| selection_group | Nhóm lựa chọn, ví dụ thể chất hoặc chuyên ngành; để trống khi chưa xác nhận. |

Khóa duy nhất: `(curriculum_code, combo_id)`. Không suy ra phạm vi áp dụng từ các mã khóa xuất hiện trong tên combo; lấy quan hệ áp dụng từ trang danh sách combo của từng khung.

## combo_courses.csv

| Cột | Ý nghĩa |
|---|---|
| curriculum_code | Mã khung đang xét. |
| combo_id | ID combo chứa môn. |
| combo_subject_id | ID dòng môn trong combo trên trang nguồn; không phải mã môn. |
| course_code | Mã môn, giữ nguyên chữ hoa/thường. |
| course_name | Tên môn theo nguồn. |
| semester | Kỳ dự kiến trong combo của khung. |
| credits | Tín chỉ, để trống khi nguồn chưa cung cấp; không mặc định 3. |
| prerequisite | Điều kiện tiên quyết; để trống nếu chưa thu thập. |
| note | Ghi chú của dòng môn trên nguồn. |

Khóa duy nhất theo nguồn: `(curriculum_code, combo_id, combo_subject_id)`. Cần kiểm tra thêm môn trùng trong cùng combo; không tự xóa nếu chưa xác định lý do.

## combo_slot_mapping.csv

| Cột | Ý nghĩa |
|---|---|
| curriculum_code | Mã khung. |
| combo_id | Combo được chọn. |
| combo_subject_id | Dòng môn cụ thể trong combo. |
| curriculum_course_code | Mã học phần lựa chọn/nhóm môn trong bảng môn của khung mà môn cụ thể thay thế. |
| curriculum_semester | Kỳ của học phần lựa chọn trong khung. |

Ánh xạ phải có căn cứ từ trường; không dựa riêng vào kỳ học trùng nhau. Chưa có ánh xạ thì chưa tính tổng tín chỉ sau khi triển khai combo. Khi ánh xạ được xác nhận, thay dòng học phần lựa chọn bằng môn cụ thể, không cộng đồng thời cả hai. Môn đã có trong phần bắt buộc cần kiểm tra trùng và quy định công nhận.

## student_combos.csv

| Cột | Ý nghĩa |
|---|---|
| student_id | Mã sinh viên trong student.csv. |
| curriculum_code | Khung của sinh viên tại thời điểm chọn. |
| combo_id | Combo sinh viên đã chọn và được phép chọn trong khung. |

Khóa duy nhất: `(student_id, curriculum_code, combo_id)`. Giới hạn số combo trong từng selection_group cần được xác nhận trước khi sinh dữ liệu. Không tự gán combo cho sinh viên chưa đến thời điểm chọn.

## Ví dụ xác nhận từ ảnh người dùng

Khung `BIT_IS_K19D_K20A`, curriculum ID 3230, có các combo ID: 26, 334, 2634, 2641, 2734, 2754. Danh sách này chỉ xác nhận cho khung trong ảnh, chưa áp dụng sang các khung IS khác.

Combo 2734: `IS_COM1.2: Topic on Enterprise Information System_Chủ đề Hệ thống thông tin Doanh nghiệp_K19D`.

| combo_subject_id | course_code | course_name | semester |
|---|---|---|---:|
| 7421 | IMO301c | IT Service Management and Operations_Quản lý và Vận hành Dịch vụ Công nghệ Thông tin | 5 |
| 7422 | KMS301 | Knowledge management system_Hệ thống quản trị tri thức | 7 |
| 7423 | DSS301 | Decision Support Systems_Hệ thống hỗ trợ ra quyết định | 7 |
| 7424 | BPS301 | Business Process Management Systems_Hệ thống quản lý quy trình kinh doanh | 8 |

Ảnh chi tiết không có tín chỉ và tiên quyết; chưa suy ra hai thông tin này. ID 7421–7424 là ID dòng, không dùng thay cho course_code.

## Nguồn cần thu thập tiếp

Lưu trang danh sách combo của từng khung và trang chi tiết từng combo trong `raw/combo/<curriculum_code>/`. Đặt tên `combo_list.html` và `combo_<combo_id>.html`. Cần cả trang danh sách để biết combo nào được phép trong khung, không chỉ trang chi tiết môn.

Trạng thái: thiết kế và ví dụ từ ảnh; chưa tạo lựa chọn combo của sinh viên, chưa sửa student.csv hoặc các CSV môn đã xác nhận.
