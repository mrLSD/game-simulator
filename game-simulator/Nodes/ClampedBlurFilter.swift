//
//  ClampedBlurFilter.swift
//  game-simulator
//

import CoreImage

/// Gaussian blur that clamps the source to its extent before blurring, so the
/// result stays opaque to the very edges — no transparent/darkened halo around
/// a full-screen image. Used to cross-blur between screens.
final class ClampedBlurFilter: CIFilter {
    @objc dynamic var inputImage: CIImage?
    var inputRadius: CGFloat = 0

    override var outputImage: CIImage? {
        guard let inputImage else { return nil }
        guard let blur = CIFilter(name: "CIGaussianBlur") else { return inputImage }
        blur.setValue(inputImage.clampedToExtent(), forKey: kCIInputImageKey)
        blur.setValue(inputRadius, forKey: kCIInputRadiusKey)
        return blur.outputImage?.cropped(to: inputImage.extent)
    }
}
