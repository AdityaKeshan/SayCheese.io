import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
part 'mine.g.dart';
@RestApi(baseUrl: "http://192.168.1.2 :3000")
abstract class ApiClient {
  factory ApiClient(Dio dio){
    dio.options = BaseOptions(receiveTimeout: 5000, connectTimeout: 5000);
    return _ApiClient(dio, baseUrl: "http://192.168.1.2:3000");}
  @POST("/image")
  Future<String> getInfo(@Body() Post a);
}

class Post {
  String img;
  Post({this.img});
  factory Post.fromJson(Map<String,dynamic> json){
    return Post(
      img:json['imgString']
    );
  }
  Map<String,dynamic> toJson()=>{
    'imgString':img
  };
}