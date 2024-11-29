// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
//
// late final ImagePicker _imagePicker;
// late final ImageCropper _imageCropper;
//
// Future<XFile?> pickImage({
// ImageSource source=ImageSource.gallery,
//   int imageQuality=100,
// }) async{
//   return await _imagePicker.pickImage(source: source,imageQuality: imageQuality);
// }
//
// Future<CroppedFile?> crop({
// required XFile file,
// CropStyle cropStyle=CropStyle.rectangle,
// }) async{
//  return await _imageCropper.cropImage(
//    sourcePath: file.path,
//    cropStyle:cropStyle,
//  );
// }