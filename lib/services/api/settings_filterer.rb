module Api
  class SettingsFilterer
    def self.filter_for(user)
      new(user).fetch
    end

    attr_reader :user, :settings, :whitelist

    def initialize(user, settings = Settings.to_hash.deep_stringify_keys, whitelist = ApiConfig.collections[:settings][:categories])
      @user = user
      @settings = settings
      @whitelist = whitelist
    end

    def fetch
      return settings if user.super_admin_user?
      whitelist.each_with_object({}) { |category_path, result| result.deep_merge!(slice_for(category_path))}
    end

    private

    def slice_for(category_path)
      SettingsSlicer.slice(settings, *category_path.split("/"))
    end
  end
end
