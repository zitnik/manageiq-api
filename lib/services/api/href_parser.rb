module Api
  class HrefParser
    def self.parse(href)
      new(href).parse
    end

    def initialize(href)
      @href = href
    end

    def parse
      return [nil, nil] unless href
      [subject, subject_id]
    end

    private

    attr_reader :href

    def subject
      (subcollection? ? subcollection : collection).to_sym
    end

    def subject_id
      subcollection? ? subcollection_id : collection_id
    end

    def subcollection?
      !!subcollection
    end

    def path
      @path ||= remove_trailing_slashes(fully_qualified? ? URI.parse(href).path : ensure_prefix(href))
    end

    def fully_qualified?
      href =~ /^http/
    end

    def remove_trailing_slashes(str)
      str.sub(/\/*$/, '')
    end

    def ensure_prefix(str)
      result = str.dup
      result.prepend("/")     unless result.start_with?("/")
      result.prepend("/api")  unless result.start_with?("/api")
      result
    end

    def collection
      path_parts[version? ? 3 : 2]
    end

    def collection_id
      ensure_uncompressed(path_parts[version? ? 4 : 3])
    end

    def subcollection
      path_parts[version? ? 5 : 4]
    end

    def subcollection_id
      ensure_uncompressed(path_parts[version? ? 6 : 5])
    end

    def ensure_uncompressed(id)
      Api.compressed_id?(id) ? Api.uncompress_id(id) : id
    end

    def version?
      @version ||= !!(Api::VERSION_REGEX =~ path_parts[2])
    end

    def path_parts
      @path_parts ||= path.split("/")
    end
  end
end
