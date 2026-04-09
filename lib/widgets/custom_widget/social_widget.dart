import 'package:flutter/material.dart';

class SocialAccountWidget extends StatefulWidget {
  final String platformName;
  final String accountName;
  final String password;

  const SocialAccountWidget({
    Key? key,
    required this.platformName,
    required this.accountName,
    required this.password,
  }) : super(key: key);

  @override
  State<SocialAccountWidget> createState() => _SocialAccountWidgetState();
}

class _SocialAccountWidgetState extends State<SocialAccountWidget> {
  bool _obscurePassword = true;
  bool _isEditing = false;

  late TextEditingController _accountController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController(text: widget.accountName);
    _passwordController = TextEditingController(text: widget.password);
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'edit':
        setState(() {
          _isEditing = true;
        });
        break;
      case 'delete':
      // TODO: Thêm xử lý xoá nếu cần
        break;
    }
  }

  void _onSave() {
    setState(() {
      _isEditing = false;
      // TODO: Gửi dữ liệu cập nhật lên server hoặc controller tại đây nếu cần
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Tiêu đề và menu 3 chấm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.platformName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                !_isEditing
                    ? PopupMenuButton<String>(
                  onSelected: _onMenuSelected,
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                    const PopupMenuItem(value: 'delete', child: Text('Xoá')),
                  ],
                  icon: const Icon(Icons.more_vert),
                )
                    : IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: _onSave,
                )
              ],
            ),
            const SizedBox(height: 8),

            /// Tài khoản
            _isEditing
                ? TextField(
              controller: _accountController,
              decoration: const InputDecoration(labelText: 'Tài khoản'),
            )
                : Text(
              'Tài khoản: ${_accountController.text}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            /// Mật khẩu
            Row(
              children: [
                Expanded(
                  child: _isEditing
                      ? TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: const InputDecoration(labelText: 'Mật khẩu'),
                  )
                      : Text(
                    _obscurePassword
                        ? 'Mật khẩu: ••••••••'
                        : 'Mật khẩu: ${_passwordController.text}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
