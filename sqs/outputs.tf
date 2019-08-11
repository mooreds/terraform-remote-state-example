output "queue_url" {
  value = "${aws_sqs_queue.myqueue.id}"
}

output "queue_arn" {
  value = "${aws_sqs_queue.myqueue.arn}"
}

