# Criando Tópico SNS
resource "aws_sns_topic" "projeto-events" {
  name = "${var.tag-base}-events"
}

resource "aws_sns_topic_subscription" "projeto-events-email" {
  topic_arn = aws_sns_topic.projeto-events.arn
  protocol  = "email"
  endpoint  = var.sns-email
}
