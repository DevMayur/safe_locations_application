import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//providers
import '../provider/authentication_provider.dart';
import '../provider/users_page_provider.dart';

//widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_input_fields.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/rounded_button.dart';

//models
import '../models/chat_user.dart';

class UsersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UsersPageState();
  }
}

class _UsersPageState extends State<UsersPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late UsersPageProvider _pageProvider;


  final TextEditingController _searchFieldTextEditingController = TextEditingController();
  final TextEditingController _groupNameFieldTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsersPageProvider>(create: (_) => UsersPageProvider(_auth)),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(builder: (BuildContext _context) {
      _pageProvider = _context.watch<UsersPageProvider>();
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopBar(
              "Users",
              primaryAction: IconButton(
                icon: const Icon(Icons.logout),
                color: const Color.fromRGBO(0, 82, 218, 1.0),
                onPressed: () {
                  _auth.logOut();
                },
              ),
              onTap: () {},
            ),
            CustomTextField(
              onEditingComplete: ( _value ) {
                _pageProvider.getRegisteredContacts(name : _value);
                FocusScope.of(context).unfocus();
              },
              hintText: 'Search',
              obscureText: false,
              controller: _searchFieldTextEditingController,
              icon: Icons.search,
            ),
            _usersList(),
            (_pageProvider.selectedUsers.length > 1) ? _groupName() : Container(),
            _createChatButton(),
          ],
        ),
      );
    });
  }

  Widget _usersList() {
    List<ChatUser>? _users = _pageProvider.registeredUsers;
    return Expanded(
      child: () {
        if(_users != null) {
          if (_users.isNotEmpty ) {
            return ListView.builder(
                itemCount: _users.length,
                itemBuilder: (BuildContext _context, int _index) {
                  return CustomListViewTile(
                      height: _deviceHeight * 0.10,
                      title: _users[_index].name,
                      subtitle: "Last Active: ${_users[_index].lastDayActive()}",
                      imagePath: _users[_index].imageURL,
                      isActive: _users[_index].isAtSafeLocation(),
                      isSelected: _pageProvider.selectedUsers.contains(_users[_index]),
                      onTap: () {
                        _pageProvider.updateSelectedUsers(_users[_index]);
                      });
                });
          } else {
            return const Center(
              child: Text(
                "No Users found",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      }(),
    );
  }
  
  Widget _createChatButton() {
    return Visibility(
      visible: _pageProvider.selectedUsers.isNotEmpty,
      child: RoundedButton(
          name: _pageProvider.selectedUsers.length == 1
              ? "Start Conversation with ${_pageProvider.selectedUsers.first.name}"
              : "Create Group Chat",
          height: _deviceHeight * 0.08,
          width: _deviceWidth * 0.80,
          onPressed: () {
            _pageProvider.createChat();
          }),
    );
  }

  Widget _groupName() {
   return CustomTextField(
      onEditingComplete: ( _value ) {
        _pageProvider.setGroupName(name : _value);
        FocusScope.of(context).unfocus();
      },
      hintText: 'Enter group name .. ',
      obscureText: false,
      controller: _groupNameFieldTextEditingController,
      icon: Icons.group_add,
    );
  }

}