locals {
    account_id = data.aws_caller_identity.current.account_id
    zone_id = data.aws_route53_zone.example.id
    region = data.aws_region.current.name

    subject_alternative_names = ["www.${var.domain_name}", "${var.domain_name}", "media.${var.domain_name}"]
    user_data = "<<-EOF sudo apt update && sudo apt upgrade -y EOF"
    #user_data = "<<-EOF sudo apt update && sudo apt upgrade -y && npm cache clean -f && sudo npm install -g n && sudo n 18 && sudo cp --remove-destination /usr/local/bin/node /opt/bitnami/node/bin/ && sudo /opt/bitnami/ctlscript.sh stop && sudo npm install -g ghost-cli@latest --unsafe-perm=true --allow-root --verbose && sudo /opt/bitnami/ctlscript.sh start && cd /opt/bitnami/ghost/ && sudo chown -R ghost:ghost /opt/bitnami/ghost/ && sudo -u ghost ghost update && sudo chown bitnami /opt/bitnami/ghost/ && sudo chown bitnami /opt/bitnami/ghost/.ghost-cli && sudo chown -R 1000:1000 '/root/.npm' && sudo -u bitnami sudo cp /opt/bitnami/ghost/config.production.json /opt/bitnami/ghost/config.production.json.bkp && sudo -u bitnami ghost config from mail@${local.domain} && sudo -u bitnami ghost config mail SMTP && sudo -u bitnami ghost config mailservice SES && sudo -u bitnami ghost config mailuser ${aws_iam_access_key.access_key.id} && sudo -u bitnami ghost config mailpass ${aws_iam_access_key.access_key.ses_smtp_password_v4} && sudo -u bitnami ghost config mailhost email-smtp.${var.region_name}.amazonaws.com && sudo -u bitnami ghost config mailport 587 && sudo -u bitnami ghost config url https://www.${local.domain} && sudo /opt/bitnami/ctlscript.sh restart EOF"

}