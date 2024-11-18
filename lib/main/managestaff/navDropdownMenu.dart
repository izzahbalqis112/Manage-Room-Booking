import 'package:dropdown_model_list/dropdown_model_list.dart';
import 'package:flutter/material.dart';

class NavDropdownMenu extends StatefulWidget {
  const NavDropdownMenu({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<NavDropdownMenu> createState() => _NavDropdownMenuState();
}

class _NavDropdownMenuState extends State<NavDropdownMenu> {
  DropListModel dropListModel = DropListModel([
    OptionItem(id: "1", title: "Manager"),
    OptionItem(id: "2", title: "Staff")
  ]);
  OptionItem optionItemSelected = OptionItem(title: "View All");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2), 
              child: SelectDropList(
                itemSelected: optionItemSelected,
                dropListModel: dropListModel,
                showIcon: true,
                showArrowIcon: true,
                showBorder: true,
                paddingTop: 0,
                icon: const Icon(Icons.people, color: Colors.white),
                onOptionSelected: (optionItem) {
                  setState(() {
                    optionItemSelected = optionItem;
                  });
                  switch (optionItem.title) {
                    case "Manager":
                      Navigator.pushNamed(context, '/viewManager');
                      break;
                    case "Staff":
                      Navigator.pushNamed(context, '/viewStaff');
                      break;
                    default:
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Unknown option selected'),
                      ));
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
