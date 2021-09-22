resource "aws_kms_key" "kky_template" {
    enable_key_rotation     = true
    deletion_window_in_days = 7
}