dashboard "Slack" {

  tags = {
    service = "Steampipe Stats"
  }

  container {
    text {
      width = 6
      value = <<EOT
[Hacker News](${local.host}/steampipe_stats.dashboard.HackerNews)
🞄
[Mods](${local.host}/steampipe_stats.dashboard.Mods)
🞄
[News](${local.host}/steampipe_stats.dashboard.News)
🞄
[Repos](${local.host}/steampipe_stats.dashboard.Repos)
🞄
Slack
🞄
[Stargazers](${local.host}/steampipe_stats.dashboard.Stargazers)
🞄
[Traffic](${local.host}/steampipe_stats.dashboard.Traffic)
🞄
[Twitter](${local.host}/steampipe_stats.dashboard.Twitter)
.
[Vercel](${local.host}/steampipe_stats.dashboard.Vercel)
      EOT
    }
  }

  card {
    width = 2
    sql = <<EOQ
      select 
        count(*) as members
      from 
        slack_user
    EOQ
  }

  container {
                                                                                                                                                                                                                                                                                                           
    chart {
      title = "New members by month"
      width = 6
      type = "line"
      sql = <<EOQ
        with months as (
          select
            to_char(updated, 'YYYY-MM') as month
          from 
            slack_user
          where
            updated is not null
        )
        select
          month,
          count(*)
        from
          months
        where 
          month <= ( select to_char(now(), 'YYYY-MM') )
        group by
          month
      EOQ
    }

  chart {
      title = "Cumulative members by month"
      width = 6
      type = "line"
      sql = <<EOQ
        with data as (
          with months as (
            select
              to_char(updated, 'YYYY-MM') as month
            from 
              slack_user
            where
              updated is not null
          )
          select
            month,
            count(*)
          from
            months
          where 
            month <= ( select to_char(now(), 'YYYY-MM') )
          group by
            month
        )
          select
            month,
            sum(count) over (order by month asc rows between unbounded preceding and current row)
          from
            data
      EOQ
    }

  }

  container {

    chart {
      width = 3
      type = "donut"
      title = "Members by tz region"
      sql = <<EOQ
        with data as (
          select
            (regexp_match(tz, '^(.+)/'))[1] as region
          from 
            slack_user
        )
        select
          region,
          count(*)
        from 
          data
        group by 
          region 
        order by
          count desc    
        EOQ
    }

    chart {
      width = 3
      type = "donut"
      title = "Members by tz city"
      sql = <<EOQ
        with data as (
          select
            (regexp_match(tz, '^.+/(.+)'))[1] as city
          from
            slack_user
        )
        select
          city,
          count(*)
        from 
          data
        group by 
          city
        order by
          count desc    
        EOQ
    }

/*
    table {
      width = 3
      title = "Members by time zone"
      type = "bar"
      sql = <<EOQ
        select 
          tz, 
          count(*) 
        from 
          slack_user 
        group by 
          tz 
        order by
        count desc    
        EOQ
      }
  */

    
  }

 
}



  