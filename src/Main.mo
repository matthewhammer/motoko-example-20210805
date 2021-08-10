import Types "Types";
import State "State";

import Buffer "mo:base/Buffer";

shared ({caller = initPrincipal})
actor class Service() {

  var state : State.State = State.empty({admin = initPrincipal});

  func getUserPosts_(caller : Principal, user : Types.Bare) : ?[Types.Post.Post] {
    do ? {
      let postIds = state.userPosts.get0({user});
      let posts = Buffer.Buffer<Types.Post.Post>(0);
      for (p in postIds.vals()) {
        posts.add(state.posts.get(p)!)
      };
      posts.toArray()
    }
  };

  func getUserSummary_(caller : Principal, user : Types.Bare) : ?Types.User.Summary {
    // to do -- protect with access control, using msg.caller
    do ? {
      let userData = state.users.get({user})!;
      {
        user;
        name = userData.name;
        createTime = userData.createTime;
      }
    }
  };

  public query(msg) func getUserSummary(user : Types.Bare) : async ?Types.User.Summary {
    getUserSummary_(msg.caller, user)
  };

  public query(msg) func getUserFull(user : Types.Bare) : async ?Types.User.Full {
    do ? {
      let summary = getUserSummary_(msg.caller, user)!;
      let posts = getUserPosts_(msg.caller, user)!;
      {
        summary;
        posts;
      }
    }
  };


}
