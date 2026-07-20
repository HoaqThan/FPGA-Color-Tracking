⚡ FPGA Real-Time 3x3 Convolution Processor
Bộ xử lý ảnh nhân chập 3x3 thời gian thực trên FPGA (Blur & Sharpening)

VerilogPythonSimulation

📖 Tổng quan hệ thống (System Overview)
Dự án tập trung vào việc thiết kế và hiện thực hóa bộ xử lý ảnh thời gian thực trên FPGA sử dụng thuật toán Nhân chập 3x3 (3x3 Convolution). Hệ thống thực hiện hai bộ lọc phổ biến là Làm mờ (Blur) và Tăng độ sắc nét (Sharpening).

Kiến trúc được tối ưu hóa bằng Pipeline và Cây cộng (Adder Tree), đảm bảo đạt thông lượng cực cao: Mỗi pixel được xử lý trong mỗi chu kỳ clock (1 pixel/clock cycle).

Luồng数据处理 (Co-Simulation Workflow)
flowchart LR    A[🖼️ Ảnh PNG 64x64] -->|1. image_to_hex.py| B[📄 test_input.hex]    B -->|2. Testbench nạp tuần tự| C[⏱️ FPGA Processing]    C --> D{Chọn mode?}    D -->|0: Sharpen| E[cnn_sharpening.v]    D -->|1: Blur| F[cnn_blur.v]    E --> G[📄 output_data.hex]    F --> G    G -->|3. hex_to_image.py| H[🖼️ Ảnh Kết quả]
🏗️ Sơ đồ khối tổng quát
(Thay thế đường link bên dưới bằng ảnh sơ đồ khối của bạn)

<p align="center">
<img src="https://via.placeholder.com/800x400.png?text=Chen+So+Do+Khoi+Block+Diagram+vao+day" alt="Sơ đồ khối hệ thống" width="800"/>
</p>

📂 Cấu trúc Module & Tệp tin
3.1. Hardware Modules (Verilog RTL)
#
Module
File
Vai trò
1	top_module	top_module.v	Module top cấp cao nhất, kết nối toàn bộ hệ thống.
2	line_buffer	line_buffer.v	Lưu trữ 2 dòng dữ liệu ảnh (chuyển đổi serial sang song song).
3	window_3x3	window_3x3.v	Trích xuất cửa sổ 3x3 pixel (p11 đến p33) từ Line Buffer.
4	cnn_sharpening	cnn_sharpening.v	Thực hiện phép nhân chập với Kernel làm sắc nét.
5	cnn_blur	cnn_blur.v	Thực hiện phép nhân chập với Kernel làm mờ.
6	testbench_prj	testbench_prj.v	Mô phỏng, nạp ảnh từ file hex và kiểm chứng đầu ra.

3.2. Software Utilities & Data Files
#
Filename
Loại
Mô tả
1	image_to_hex.py	Pre-processing	Chuyển ảnh (png) sang ma trận pixel .hex cho Testbench.
2	hex_to_image.py	Post-processing	Đọc kết quả từ ModelSim, tái tạo thành file ảnh.
3	test_input.hex	Data	Chứa dữ liệu ảnh gốc 64x64.
4	output_data.hex	Data	Chứa dữ liệu ảnh sau khi qua Convolution.
5	image_source/	Directory	Chứa ảnh mẫu Input và Output.

🔌 Đặc tả Chân tín hiệu I/O (Interface Specifications)
🔍 Click để xem chi tiết chân tín hiệu từng module
⚙️ Luồng hoạt động hệ thống (System Workflow)
1. Chuẩn bị và nạp dữ liệu (Input Stage)
Tiền xử lý (Python): Ảnh gốc được image_to_hex.py chuyển thành ma trận 8-bit lưu vào test_input.hex.
[Chèn ảnh: Màn hình thư mục chứa code python và ảnh test]
Nạp dữ liệu: Trong testbench_prj.v (Ví dụ: Dòng 46), file .hex được đọc và đẩy tuần tự từng pixel qua cổng i_pixel tại mỗi sườn dương của i_clk.
2. Xử lý Convolution (Processing Stage)
Đệm dữ liệu: Module line_buffer.v nhận pixel đơn lẻ, dịch chuyển qua các thanh ghi để tạo 2 dòng đệm.
Tạo cửa sổ 3x3: Module window_3x3.v trích xuất ma trận 3x3 (p11 đến p33).
Tính toán: Tùy thuộc vào mode, MUX sẽ đưa ma trận này vào cnn_sharpening.v hoặc cnn_blur.v. Tại đây, các pixel nhân với hệ số Kernel và cộng dồn qua Adder Tree.
3. Xuất và Tái tạo ảnh (Output Stage)
Đồng bộ hoá: Tín hiệu data_valid_out được kích hoạt khi o_pixel ổn định.
Hậu xử lý (Python): Dữ liệu ghi vào output_data.hex được script hex_to_image.py đọc và tái tạo thành ảnh.
[Chèn ảnh: 2 file .hex được mở bằng text editor]
📊 Kết quả Mô phỏng & Kiểm chứng
1. Kết quả Waveform (ModelSim)
Hình dưới thể hiện sự phối hợp nhịp nhàng của Pipeline:

[Chèn Ảnh 1: Waveform phân tích data_valid và window p11-p33]
[Chèn Ảnh 2: Waveform phân tích đầu ra o_pixel và Adder Tree]

Đánh giá tín hiệu:

data_valid_in / data_valid_out: Hoạt động nhịp nhàng, bảo đảm không ghi rác.
p11 đến p33: Cửa sổ trượt 3x3 được trích xuất hoàn hảo mỗi chu kỳ clock.
o_pixel: Giá trị tính toán từ Adder Tree xuất ra ngay lập tức, không bị gián đoạn.
2. Kết quả Trực quan (Visual Results)
Sau khi chạy script hậu xử lý, đối chiếu trực quan như sau:

Ảnh gốc (Input - Grayscale 64x64)
Kết quả Sharpening (FPGA)
Kết quả Blurring (FPGA)
[Chèn ảnh: input_original.png]	[Chèn ảnh: output_sharp.png]	[Chèn ảnh: output_blur.png]

🧪 Đánh giá và Nhận xét (Evaluation & Analysis)
Dựa trên kết quả mô phỏng phần cứng và hình ảnh tái tạo, hệ thống đạt các kết quả thực nghiệm sau:

Chức năng tiền xử lý (Grayscale Conversion): Ảnh RGB được hạ mẫu (downsample) về 64x64 và chuyển sang Grayscale 8-bit thành công. Cấu trúc hình khối, đường nét được giữ nguyên, đảm bảo luồng dữ liệu nạp vào i_pixel mượt mà.
Hiệu năng bộ lọc Sharpening: Các đường biên, góc cạnh và chi tiết vân được tăng cường tương phản rất mạnh (xuất hiện vùng biên trắng/đen rõ rệt).
Giải thích kỹ thuật: Lõi cnn_sharpening thực thi chính xác Kernel (trọng số cao ở tâm, hệ số âm xung quanh). Cấu trúc Adder Tree không bị tràn số (overflow) nhờ thuật toán bão hòa dữ liệu (Clipping Logic) hoạt động chuẩn xác.
Hiệu năng bộ lọc Blurring: Toàn bộ chi tiết nhiễu gai bị triệt tiêu, bức ảnh mịn màng rõ rệt.
Giải thích kỹ thuật: Module cnn_blur thực hiện đúng bản chất của bộ lọc thông thấp (Low-pass Filter), cào bằng sự chênh lệch năng lượng giữa các pixel lân cận.
Tính đồng bộ của Hệ thống: Hình ảnh không bị méo tuyến tính hay lệch hàng/cột. Khẳng định quản lý địa chỉ trượt pixel của line_buffer và window_3x3 hoàn toàn đồng bộ, không mất mát dữ liệu tại biên ảnh (Boundary pixels).
🏁 Kết luận
Thiết kế phần cứng trên FPGA đáp ứng hoàn hảo yêu cầu xử lý ảnh thời gian thực, cho kết quả trực quan chính xác tuyệt đối so với thuật toán lý thuyết. Việc áp dụng kiến trúc Pipeline kết hợp Adder Tree đã tối ưu hóa triệt để tài nguyên phần cứng và tốc độ xử lý của bộ lọc Convolution 3x3.

<div align="center">
Made with ❤️ for FPGA Hardware Design
</div>
```
