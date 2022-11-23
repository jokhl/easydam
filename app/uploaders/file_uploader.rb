class FileUploader < Shrine
  Attacher.derivatives do |original|
    vips = ImageProcessing::Vips.source(original).convert("jpg")
    
    {
      small: vips.resize_to_limit!(400, 400),
      medium: vips.resize_to_limit!(800, 800),
      large: vips.resize_to_limit!(1200, 1200)
    }
  end
end
