
## определение IAM роли

resource "aws_iam_role" "vb_ecs_events" {
  name = "ecs_events-${local.name}"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

# IAM policy 
resource "aws_iam_role_policy" "vb_ecs_events_run_task" {
  name = "ecs-events-run-task-${local.name}"
  role = "${aws_iam_role.vb_ecs_events.id}"

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ecs:RunTask",
            "Resource": "${replace(module.web_console.task_definition_arn, "/:\\d+$/", ":*")}"
        }
    ]
}
DOC
}

## Расписание по которому будет выполняться команда
resource "aws_cloudwatch_event_rule" "vb_crons_rules" {

  count = "${length(var.crons_shedule)}"

  name                = "cron-${local.name}"
  description         = "shedule ro crons"
  schedule_expression = "${var.crons_shedule[count.index]}"

}

## Выполняет команду

resource "aws_cloudwatch_event_target" "vb_ecs_scheduled_task" {
  count = "${length(var.crons_tasks)}"

  target_id = "run-scheduled-tasks"
  arn       = "${module.ecs_cluster.cluster_arn}"
  rule      = "${element(aws_cloudwatch_event_rule.vb_crons_rules.*.name, count.index)}"
  role_arn  = "${aws_iam_role.vb_ecs_events.arn}"

  ecs_target = {
    task_count          = 1
    task_definition_arn = "${module.web_console.task_definition_arn}"
  }

  input = <<DOC
{
  "containerOverrides": [
    {
      "name": "${var.web_console_image}",
      "command": $[var.crons_tasks[count.index]]
    }
  ]
}
DOC
}

resource "aws_cloudwatch_log_group" "crons" {
  name = "/crons/${local.name}"
}
