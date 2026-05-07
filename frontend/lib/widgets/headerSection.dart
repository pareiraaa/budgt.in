import 'package:flutter/material.dart';

class Headersection extends StatelessWidget {
  final String? name;
  // final User? user;

  const Headersection({
    super.key,
    this.name
  });

  @override
  Widget build(BuildContext context) {
    //ganti pas udah make user, bukan string lagi
    final hasName = name!=null && name!.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //greetings
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasName ? 'Hello, $name!' : 'Hello!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              hasName ? 'Welcome back!' : 'Welcome',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),

        //avatar
        GestureDetector(
          onTap: (){
            if(hasName){
              Navigator.pushNamed(context, '/settings');
            } else {
              Navigator.pushNamed(context, '/login');
            }
          },

          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.deepPurple,

            child: hasName
              ? Text(
                name![0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              )

              : const Icon(
                Icons.person,
                color: Colors.white
              )
            // child: Text(
            //   hasName ? name![0].toUpperCase() : '',
            //   style: const TextStyle(
            //     color: Colors.white, fontSize: 18
            //   )
            // ),
          ),
        )
        
      ],
    );
  }
}
