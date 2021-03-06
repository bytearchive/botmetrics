class ReportsMailer < ApplicationMailer
  def daily_summary(user_id)
    @user = User.find(user_id)
    return if @user.bots.count == 0

    User.with_advisory_lock("reports-mailer-daily-summary-#{@user.id}") do
      if monday_in_time_zone?(@user.timezone)
        @weekly_dashboarders = []

        @user.bots.each do |bot|
          @weekly_dashboarders << bot
        end
      end

      @daily_dashboarders = []

      @user.bots.each do |bot|
        @daily_dashboarders << bot
      end

      opts = {
        to: @user.email,
        subject: "Your botmetrics Daily Summary for #{yesterday_in_words(@user)}"
      }

      mail(opts)

      @user.log_daily_summary_sent
    end
  end

  private
  def monday_in_time_zone?(time_zone)
    Time.current.in_time_zone(time_zone).monday?
  end

  def yesterday_in_words(user)
    (Time.current.in_time_zone(user.timezone) - 1.day).strftime('%b %d, %Y')
  end
end
