resource "aws_elasticache_cluster" "redis" {
    cluster_id           = "redis-${var.tag-base}"
    engine               = "redis"
    # engine_version       = "7.0"
    node_type            = "cache.t3.micro"
    num_cache_nodes      = 1
    parameter_group_name = "default.redis7"
    port                 = 6379  # A porta padrão do Redis é 6379
    security_group_ids   = [aws_security_group.sg_projeto_cache.id]
    subnet_group_name    = aws_elasticache_subnet_group.elasticache-subnet-group.name
}

resource "aws_elasticache_subnet_group" "elasticache-subnet-group" {
    name       = "elasticache-subnet-group"
    subnet_ids = [
        aws_subnet.sn-projeto-public-1.id,
        aws_subnet.sn-projeto-public-2.id,
        aws_subnet.sn-projeto-public-3.id,
        aws_subnet.sn-projeto-private-1.id,
        aws_subnet.sn-projeto-private-2.id,
        aws_subnet.sn-projeto-private-3.id
    ]
}