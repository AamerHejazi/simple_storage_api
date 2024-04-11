module BlobStorageInterface
    def store(id, data, size, user)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end
  
    def retrieve(blob_id, user)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end
end
  