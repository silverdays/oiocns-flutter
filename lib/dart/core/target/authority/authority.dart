import 'package:orginone/dart/core/public/entity.dart';
import 'package:orginone/dart/base/model.dart';
import 'package:orginone/dart/base/schema.dart';
import 'package:orginone/dart/core/chat/message/msgchat.dart';
import 'package:orginone/dart/core/public/enums.dart';
import 'package:orginone/dart/core/target/base/belong.dart';
import 'package:orginone/main.dart';

abstract class IAuthority extends IEntity<XAuthority> {
  /// 加载权限的自归属用户
  late IBelong space;

  /// 拥有该权限的成员
  late List<XTarget> members;

  /// 父级权限
  IAuthority? parent;

  /// 子级权限
  late List<IAuthority> children;

  /// 深加载
  Future<void> deepLoad({bool reload = false});

  ///加载成员实体
  Future<List<XTarget>> loadMembers({bool? reload});

  /// 创建权限
  Future<IAuthority?> create(XAuthority data, {bool? notity});

  /// 更新权限
  Future<bool> update(AuthorityModel data);

  /// 删除权限
  Future<bool> delete({bool? notity});

  /// 根据权限id查找权限实例
  IAuthority? findAuthById(String authId, {IAuthority? auth});

  /// 根据权限获取所有父级权限Id
  List<String> loadParentAuthIds(List<String> authIds);

  /// 判断是否拥有某些权限
  bool hasAuthoritys(List<String> authIds);

  ///接收职权变更消息
  Future<bool> receiveAuthority(AuthorityOperateModel data);
}

class Authority extends Entity<XAuthority> implements IAuthority {
  @override
  late IBelong space;

  @override
  List<XTarget> members = [];

  @override
  IAuthority? parent;
  @override
  List<IAuthority> children = [];
  @override
  late IDirectory directory;

  bool _memberLoaded = false;

  Authority(XAuthority metadata, IBelong _space, Authority authority,
      {IAuthority? parent})
      : super(metadata) {
    space = _space;
    this.parent = parent;
    for (var node in metadata.nodes ?? []) {
      children.add(Authority(node, space, this));
    }
    directory = _space.directory;
  }

  @override
  Future<List<XTarget>> loadMembers({bool? reload = false}) async {
    if (!_memberLoaded || reload!) {
      var res = await kernel.queryAuthorityTargets(GainModel(
        id: metadata.id,
        subId: space.metadata.belongId!,
      ));
      if (res.success) {
        _memberLoaded = true;
        members = res.data?.result ?? [];
      }
    }
    return members;
  }

  @override
  Future<IAuthority?> create(XAuthority data, {bool? notity = false}) async {
    if (!notity!) {
      var res = await kernel.createAuthority(AuthorityModel(
        id: data.id,
        name: data.name,
        code: data.code,
        public: data.public,
        parentId: id,
        shareId: data.shareId,
        remark: data.remark,
        icon: data.icon,
      ));
      if (!res.success) return null;
      data = res.data!;
      await space.sendAuthorityChangeMsg(
          OperateType.create as String, res.data!); //operate操作未实现
    }
    var authority = Authority(data, space, this);
    children.add(authority);
    return authority;
  }

  @override
  Future<bool> update(AuthorityModel data) async {
    data.id = id;
    data.shareId = metadata.shareId;
    data.parentId = metadata.parentId;
    data.name = data.name ?? name;
    data.code = data.code ?? code;
    data.icon = data.icon ?? metadata.icon;
    data.remark = data.remark ?? remark;
    final res = await kernel.updateAuthority(data);
    if (res.success && res.data?.id != null) {
      metadata = res.data!;
      share = ShareIcon(
        name: metadata.name ?? "",
        typeName: '权限',
        avatar: FileItemShare.parseAvatar(metadata.icon),
      );
    }
    return res.success;
  }

  @override
  Future<bool> delete({bool? notity = false}) async {
    if (!notity!) {
      final res = await kernel.deleteAuthority(IdReq(id: id));
      if (!res.success) return false;
      await space.sendAuthorityChangeMsg(
          OperateType.delete as String, metadata);
    }
    if (parent != null) {
      parent?.children.removeWhere((i) => i != this);
    }
    return true;
  }

  @override
  List<String> loadParentAuthIds(List<String> authIds) {
    final result = <String>[];
    for (final authId in authIds) {
      final auth = findAuthById(authId);
      if (auth != null) {
        _appendParentId(auth, result);
      }
    }
    return result;
  }

  @override
  IAuthority? findAuthById(String authId, {IAuthority? auth}) {
    auth = auth ?? space.superAuth;
    if (auth?.id == authId) {
      return auth;
    } else {
      for (final item in auth?.children ?? []) {
        final find = findAuthById(authId, auth: item);
        if (find != null) {
          return find;
        }
      }
    }
    return null;
  }

  @override
  Future<void> deepLoad({bool reload = false}) async {
    await loadMembers(reload: reload);
    await Future.wait(
        children.map((item) async => await item.deepLoad(reload: reload)));
  }

  @override
  bool hasAuthoritys(List<String> authIds) {
    authIds = loadParentAuthIds(authIds);
    final orgIds = [metadata.belongId ?? ""];
    if (metadata.shareId != null && metadata.shareId != null) {
      orgIds.add(metadata.shareId!);
    }
    return space.user.authenticate(orgIds, ids);
  }

  void _appendParentId(IAuthority auth, List<String> authIds) {
    if (!authIds.contains(auth.metadata.id)) {
      authIds.add(auth.metadata.id);
    }
    if (auth.parent != null) {
      _appendParentId(auth.parent!, authIds);
    }
  }

  @override
  List<IMsgChat> get chats {
    final chats = <IMsgChat>[this];
    for (final item in children) {
      chats.addAll(item.chats);
    }
    return chats;
  }
}
