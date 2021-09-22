resource "aws_lb" "lb_template" {
    internal = false
    load_balancer_type = "network"
    enable_cross_zone_load_balancing = true
    
    subnets = [
        var.sbn_public_a.id,
        var.sbn_public_b.id,
        var.sbn_public_c.id
    ]
}


resource "aws_lb_listener" "lls_template" {
    load_balancer_arn = aws_lb.lb_template.arn
    protocol          = var.ltg_protocol
    port              = var.ltg_port
    
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.ltg_template.arn
    }
}


resource "aws_lb_target_group" "ltg_template" {
    vpc_id   = var.vpc.id
    protocol = var.ltg_protocol
    port     = var.ltg_port
}


resource "aws_lb_target_group_attachment" "tga_template_a" {
    target_group_arn = aws_lb_target_group.ltg_template.arn
    target_id = var.tga_target_a.id
}


resource "aws_lb_target_group_attachment" "tga_template_b" {
    target_group_arn = aws_lb_target_group.ltg_template.arn
    target_id = var.tga_target_b.id
}


/*
resource "aws_lb_target_group_attachment" "tga_template_c" {
    target_group_arn = aws_lb_target_group.ltg_template.arn
    target_id = var.tga_target_c.id
}
*/