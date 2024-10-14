import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel/widget/configure.dart';

class TripShimmerCard extends StatelessWidget {
  const TripShimmerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0XFFe1e1e1),
      highlightColor: const Color(0XFFeeeeee),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(
            color: kPrimaryColor,
            width: 1.5,
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: kPrimaryColor,
                              width: 3,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.verified, color: Colors.blue),
                        const SizedBox(width: 5),
                        Container(
                          color: Colors.grey[300],
                          width: 100,
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 35, bottom: 10.0, right: 20),
                    child: Container(
                      color: Colors.grey[300],
                      width: 80,
                      height: 16,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 13),
                child: Container(
                  color: Colors.grey[300],
                  width: 150,
                  height: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 13.0, left: 15),
                child: Container(
                  color: Colors.grey[300],
                  width: 200,
                  height: 16,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}


