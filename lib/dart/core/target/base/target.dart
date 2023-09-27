import 'package:orginone/dart/base/model.dart';
import 'package:orginone/dart/base/schema.dart';
import 'package:orginone/dart/core/public/enums.dart';
import 'package:orginone/dart/core/target/identity/identity.dart';
import 'package:orginone/dart/core/target/person.dart';
import 'package:orginone/dart/core/thing/directory.dart';
import 'package:orginone/main.dart';

import '../../thing/file_info.dart';
import 'team.dart';

/// 空间类型数据
class SpaceType {
  // 唯一标识
  late String id;

  // 名称
  late String name;

  // 类型
  late TargetType typeName;

  // 头像
  late ShareIcon share;
}

abstract class ITarget with ITeam, IFileInfo<XTarget> {
  //会话
  late ISession session;
  //用户资源
  late DataResource resource;
  //用户设立的身份（角色）
  late List<IIdentity> identitys;
  //子用户
  List<ITarget> get subTarget;
  //所有相关用户
  List<ITarget> get targets;
  //用户相关的所有会话
  @override
  List<ISession> get chats;
  //成员目录
  late IDirectory memberDirectory;
  //退出用户群
  Future<bool> exit();
  //加载用户设立的身份（角色）对象
  Future<List<IIdentity>> loadIdentitys({bool reload = false});
  //为用户设立身份
  Future<IIdentity?> createIdentity(IdentityModel data);
  //发送身份变更通知
  Future<bool> sendIdentityChangeMsg(dynamic data);
}

///用户基类实现
abstract class Target extends Team implements ITarget {
  IPerson user;
  //ISession session;
  @override
  IDirectory directory;
  @override
  //DataResource resource;
  bool isContainer;
  @override
  List<IIdentity> identitys;
  @override
  IDirectory memberDirectory;
  final bool _identityLoaded = false;

  Target(super.keys, super.metadata, super.relations, super.memberTypes) {
    user = user ?? (this as IPerson);
    resource = DataResource(metadata, relations, [key]);
    directory = Directory(metadata, target); //////////////////////
    memberDirectory = Directory(metadata, target);
    isContainer = true;
    session = Session(id, metadata); /////////////////////////
    kernel.subscribed('${_metadata.belongId}-${_metadata.id}-identity',
      [..._keys, key],
      (data = any) => _receiveIdentity(data),);
  }

  String get spaceId{
    return space.id;
  }
  @override
  String get locationKey{
    return id;
  }

  @override
  Future<List<IIdentity>> loadIdentitys({bool reload = false}) async {
    if (identitys.isEmpty || reload) {
      var res = await kernel.queryTargetIdentitys(IDBelongReq(
          id: metadata.id,
          page: PageRequest(offset: 0, limit: 9999, filter: '')));
      identitys.clear();
      if (res.success && res.data?.result != null) {
        for (var element in res.data!.result!) {
          identitys.add(Identity(space, element));
        }
      }
    }
    return identitys;
  }

  @override
  Future<IIdentity?> createIdentity(IdentityModel data) async {
    data.shareId = metadata.id;
    var res = await kernel.createIdentity(data);
    if (res.success && res.data?.id != null) {
      var identity = Identity(space, res.data!);
      identitys.add(identity);
      return identity;
    }
    return null;
  }

  @override
  List<OperateModel> operates(){
    var operates = super.operates();////
    if(this.session.isMyChat){
      operates.unshift(targetOperates.Chat);
    }
    if(this.members.some((i) => i.id === this.userId)){
      //operates.unshift(memberOperates.Exit);
    }
  }

  Future<bool> pullSubTarget(ITeam team) async {
    var res = await kernel.pullAnyToTeam(
        GiveModel(id: metadata.id, subIds: [team.metadata.id]));
    if(res.success){
      await sendTargetNotity(OperateType.add,team.metadata);
    }
    return res.success;
  }

  @override
  Future<bool> loadContent({bool reload = false}) async {
    await Future.wait([
      super.loadContent(reload: reload),
      loadIdentitys(reload: reload),
    ]);
    return true;
  }

  @override
  Future<bool> rename(String name)async {
    return Team.update({
      metadata,
      name: name,
      teamCode: metadata.team?.code ?? this.code,
      teamName: metadata.team?.name ?? this.name,
    });
  }
  //暂不支持
  // @override
  // bool copy(IDirectory _destination){
  //   throw Error();
  // }

  //暂不支持
  // @override
  // bool move(IDirectory _destination){
  //   throw Error();
  // }

  @override
  Future<ITeam?> createTarget(TargetModel data) async {
    return null;
  }

  @override
  Future notifySession(bool pull,List<XTarget> member){
     if (id != userId) {
      for (const member of members) {
        if (member.typeName === TargetType.Person) {
          if (pull) {
            await this.session.sendMessage(
              MessageType.Notify,
              `${user.name} 邀请 ${member.name} 加入群聊`,
              [],
            );
          } else {
            await this.session.sendMessage(
              MessageType.Notify,
              `${user.name} 将 ${member.name} 移出群聊`,
              [],
            );
          }
        }
      }
    }
  }
  @override
  Future<bool> sendIdentityChangeMsg(dynamic data)async{
    var res = await kernel.dataNotify(DataNotityType(
      data: data,
      targetId: metadata.id,
      ignoreSelf: true, 
      flag: 'identity', 
      relations: relations, 
      belongId: belongId, 
      onlyTarget: false, 
      onlineOnly: false,
    ));
    return res.success;
  }
  Future _receiveIdentity(IdentityOperateModel data){
    var message ='';
    switch (data.operate) {
      case OperateType.create:
        message = `${data.operater.name}新增身份【${data.identity.name}】.`;
        if (identitys.every((q) => q.id !== data.identity.id)) {
          identitys.push(Identity(data.identity, this));
        }
        break;
      case OperateType.delete:
        message = `${data.operater.name}将身份【${data.identity.name}】删除.`;
        await identitys.find((a) => a.id == data.identity.id)?.delete(true);
        break;
      case OperateType.update:
        message = `${data.operater.name}将身份【${data.identity.name}】信息更新.`;
        this.updateMetadata(data.identity);
        break;
      case OperateType.remove:
        if (data.subTarget) {
          message = `${data.operater.name}移除赋予【${data.subTarget!.name}】的身份【${
            data.identity.name
          }】.`;
          await identitys
            .find((a) => a.id == data.identity.id)
            ?.removeMembers([data.subTarget], true);
        }
        break;
      case OperateType.add:
        if (data.subTarget) {
          message = '${data.operater.name}赋予{${data.subTarget!.name}身份【${
            data.identity.name
          }】.';
          await identitys
            .find((a) => a.id == data.identity.id)
            ?.pullMembers([data.subTarget], true);
        }
        break;
    }
    if (message.isNotEmpty) {
      if (data.operater?.id != user.id) {
        logger.info(message);
      }
      directory.structCallback();
    }
  }
}
