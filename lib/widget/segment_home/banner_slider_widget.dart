import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:jackdigitalstore_app/provider/home_provider.dart';
import 'package:jackdigitalstore_app/screen/pages.dart';
import 'package:jackdigitalstore_app/utils/utility.dart';
import 'package:jackdigitalstore_app/widget/webview/webview.dart';
import 'package:jackdigitalstore_app/widget/widget.dart';

class MVBannerSlider extends StatelessWidget {
  const MVBannerSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, child) {
      if (value.loadingSlider) {
        return Container();
      } else {
        if (value.banners.isEmpty) {
          return Container();
        }
        return Container(
          child: CarouselSlider.builder(
            itemCount: value.banners.length,
            options: CarouselOptions(
                enableInfiniteScroll: true,
                autoPlay: true,
                height: 130.h,
                enlargeCenterPage: true,
                viewportFraction: 1),
            itemBuilder: (context, index, realIdx) {
              final banners = value.banners[index];
              return InkWell(
                  onTap: () {
                    if (banners.linkTo == 'URL') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewScreen(
                            title: banners.titleSlider,
                            url: banners.name,
                          ),
                        ),
                      );
                    }
                    if (banners.linkTo == 'category') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubCategoriesScreen(
                            id: banners.product.toString(),
                            title: banners.name,
                            nonSub: true,
                          ),
                        ),
                      );
                    }
                    if (banners.linkTo == 'blog') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailBlog(
                            id: banners.product,
                          ),
                        ),
                      );
                    }
                    if (banners.linkTo == 'product') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailProductScreen(
                            isFlashSale: false,
                            id: banners.product.toString(),
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: value.banners[index].image!,
                        fit: BoxFit.fill,
                        width: 480,
                        height: 120,
                        placeholder: (context, url) => customLoading(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ));
            },
          ),
        );
      }
    });
  }
}
