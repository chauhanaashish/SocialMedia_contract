// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SocialMedia {

    struct UserProfile {
        address userAddress;                    //unique identifier
        string username;
        string bio;
        uint postCount;
        uint commentCount;
        uint likesCount;
        
        string[] userPosts; 
        string[] userComments; 
        string[] likesGiven;                  
    }
    struct Post {
        uint postNumber;
        address author;
        string contentId;                        // unique identifier
        string[] comments;
        address[] likes;
    }
    struct Comment {
        uint commentNumber;
        address author;
        address postAddress;
        string contentHash;                     //unique identifier
    }
    
    mapping(address => UserProfile) public userProfiles;    
    mapping(string => Post) public posts;

    address[] public allUsers;
    
    event ProfileUpdated(address indexed userAddress, string username, string bio);
    event PostCreated(address indexed author, string content, uint indexed postNumber);
    event CommentAdded(address indexed author, string content, uint indexed commentNumber);
    event LikeGiven(address indexed sender, string contentHash);

    function updateProfile(string memory _username, string memory _bio) public {
        address userAddress = msg.sender;
        
        if (userProfiles[userAddress].userAddress == address(0)) {
            userProfiles[userAddress] = UserProfile(userAddress, _username, _bio,0,0,0, new string[](0), new string[](0), new string[](0));
            allUsers.push(userAddress);
        } else {
            userProfiles[userAddress].username = _username;
            userProfiles[userAddress].bio = _bio;
        }
        emit ProfileUpdated(userAddress, _username, _bio);
    }
    
    function getAllUsers() public view returns (address[] memory) {
        return allUsers;
    }    

    function createPost(string memory _contentId) public {
        address author = msg.sender;
        string memory contentId = _contentId; // _content will act as the unique identifier (from IPFS)
        
        require(userProfiles[author].userAddress != address(0), "User profile does not exist");
        
        userProfiles[author].postCount++;
        uint postNumber = userProfiles[author].postCount;
        
        posts[contentId] = Post(postNumber, author, contentId, new string[](0), new address[](0));
        //imp                                    now push this post in UserProfile Structure using mapping
        userProfiles[author].userPosts.push(contentId);

        emit PostCreated(author, contentId, postNumber);
    }
//comment identifier

    function addComment(string memory _commentId, string memory _postId) public {
        address author = msg.sender;
        string memory commentId = _commentId;
        string memory postId = _postId;
        
        require(userProfiles[author].userAddress != address(0), "User profile does not exist");
        require(posts[postId].author != address(0), "Post does not exist");
        
        userProfiles[author].commentCount++;
        uint commentNumber = userProfiles[author].commentCount;
        //imp                                    now push this comment in Post and UserProfile Structure using mapping        
        posts[postId].comments.push(_commentId);
        userProfiles[author].userComments.push(commentId);

        emit CommentAdded(author, commentId, commentNumber);
    }

    function giveLike(string memory _postId) public {
        address sender = msg.sender;
        string memory postId = _postId;
        
        require(userProfiles[sender].userAddress != address(0), "User profile does not exist");
        require(posts[postId].author != address(0), "Post does not exist");
        
        userProfiles[sender].likesCount++;
        //imp                                    now push this like in Post and UserProfile Structure using mapping
        posts[postId].likes.push(sender);
        userProfiles[sender].likesGiven.push(postId);
        
        emit LikeGiven(sender, postId);
    }

    function getPostDetails(string memory _contentId) public view returns (string[] memory, address[] memory) {
        return (posts[_contentId].comments, posts[_contentId].likes);
    }

    function getUserDetails(address _address) public view returns (string[] memory, string[] memory, string[] memory) {
        return (userProfiles[_address].userPosts, userProfiles[_address].userComments, userProfiles[_address].likesGiven);
    }   
}
