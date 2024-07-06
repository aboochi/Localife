//
//  PostManager.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/30/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class PostManager{
    
    static let shared = PostManager()
    private init() { }
    
    private let postsCollection = Firestore.firestore().collection("Posts")
    private let storiesCollection = Firestore.firestore().collection("Stories")
    private let usersCollection = Firestore.firestore().collection("users")

   
    private func postDocument(postId: String) -> DocumentReference {
        postsCollection.document(postId)
    }
    
    private func lastStoryDocument(uid: String) -> DocumentReference {
        storiesCollection.document(uid)
    }
    
    private func allStoryCollection(uid: String) -> CollectionReference {
        lastStoryDocument(uid: uid).collection("allStories")
    }
    
    private func storyDocument(ownerId: String, storyId: String) -> DocumentReference {
        allStoryCollection(uid: ownerId).document(storyId)
    }
    private func storyLikeCollection(ownerId: String, storyId: String) ->  CollectionReference {
        storyDocument(ownerId: ownerId, storyId: storyId).collection("StoryLikes")
    }
    
    private func storyLikeDocument(ownerId: String, storyId: String, uid: String) -> DocumentReference {
        storyLikeCollection(ownerId: ownerId,  storyId: storyId).document(uid)
    }
    
    private func storySeenCollection(ownerId: String, storyId: String) ->  CollectionReference {
        storyDocument(ownerId: ownerId, storyId: storyId).collection("StorySeen")
    }
    
    private func storySeenDocument(ownerId: String, storyId: String, uid: String) -> DocumentReference {
        storySeenCollection(ownerId: ownerId,  storyId: storyId).document(uid)
    }
    
    private func postLikeCollection(postId: String) ->  CollectionReference {
        postDocument(postId: postId).collection("PostLikes")
    }
    
    private func postLikeDocument(postId: String, uid: String) -> DocumentReference {
        postLikeCollection(postId: postId).document(uid)
    }
    
    private func userPostLikesCollection(uid: String) -> CollectionReference {
        usersCollection.document(uid).collection("UserPostLikes")
    }
    
    private func userPostLikesDocument(postId: String, uid: String) -> DocumentReference {
        userPostLikesCollection(uid: uid).document(postId)
    }
     // Comments
    
    private func postCommentCollection(postId: String) ->  CollectionReference {
        postDocument(postId: postId).collection("PostComments")
    }
    
    private func postCommentDocument(postId: String, commentId: String) -> DocumentReference {
        postCommentCollection(postId: postId).document(commentId)
    }
    
    private func postCommentRepliesCollection(postId: String, commentId: String) -> CollectionReference {
        postCommentDocument(postId: postId, commentId: commentId).collection("CommentReplies")
    }
    
    private func postCommentRepliesDocument(postId: String, ReplyId: String, commentId: String) -> DocumentReference {
        postCommentRepliesCollection(postId: postId, commentId: commentId).document(ReplyId)
    }
    
    private func postCommentLikesCollection(postId: String, commentId: String) -> CollectionReference {
        postCommentDocument(postId: postId, commentId: commentId).collection("CommentLikes")
    }
    
    private func postCommentLikesDocument(postId: String, uid: String, commentId: String) -> DocumentReference {
        postCommentLikesCollection(postId: postId, commentId: commentId).document(uid)
    }
    
    private func postCommentReplyLikeCollection(postId: String, ReplyId: String, commentId: String) -> CollectionReference{
        postCommentRepliesDocument(postId: postId, ReplyId: ReplyId, commentId: commentId).collection("ReplyLikes")
    }
    
    private func postCommentReplyLikeDocument(postId: String, ReplyId: String, commentId: String, uid: String) -> DocumentReference{
        postCommentReplyLikeCollection(postId: postId, ReplyId: ReplyId, commentId: commentId).document(uid)
    }
    
    
    
    func uploadPost(post: Post) async throws {
        try postDocument(postId: String(post.id)).setData(from: post, merge: false)
    }
    
    func getPost(postId: String) async throws -> Post {
        try await postDocument(postId: postId).getDocument(as: Post.self)
    }
    
    private func getAllPostsQuery() -> Query {
        postsCollection
    }
    
    private func getAllPostsSortedByTimeQuery(descending: Bool) -> Query {
        postsCollection
            .order(by: Post.CodingKeys.time.rawValue, descending: descending)
    }
    
    private func getAllPostsForCategoryQuery(category: String) -> Query {
        postsCollection
            .whereField(Post.CodingKeys.category.rawValue, isEqualTo: category)
    }
    
    private func getAllPostsByTimeAndCategoryQuery(descending: Bool, category: String) -> Query {
        postsCollection
            .whereField(Post.CodingKeys.category.rawValue, isEqualTo: category)
            .order(by: Post.CodingKeys.time.rawValue, descending: descending)
    }
    
    func getAllPosts(timeDescending descending: Bool?, forCategory category: String?, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [Post], lastDocument: DocumentSnapshot?) {
        var query: Query = getAllPostsQuery()
        
        if let descending, let category {
            query = getAllPostsByTimeAndCategoryQuery(descending: descending, category: category)
        } else if let descending {
            query = getAllPostsSortedByTimeQuery(descending: descending)
        } else if let category {
            query = getAllPostsForCategoryQuery(category: category)
        }
        
        
        return try await query
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
        
    }
    
    
    
    func getPostsByTime(count: Int, time: Double?) async throws -> [Post] {
        try await postsCollection
            .order(by: Post.CodingKeys.time.rawValue, descending: true)
            .limit(to: count)
            //.start(after: [lastRating ?? 9999999])
            .getDocuments(as: Post.self)
    }
    
    func getPostsByTime(count: Int,  lastTime: Timestamp,  lastDocument: DocumentSnapshot?) async throws -> (output: [Post], lastDocument: DocumentSnapshot?) {
        if let lastDocument = lastDocument {
            return try await postsCollection
                //.whereField(Post.CodingKeys.time.rawValue, isGreaterThan: lastTime)
                .order(by: Post.CodingKeys.time.rawValue, descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Post.self)
        } else {
            return try await postsCollection
                //.whereField(Post.CodingKeys.time.rawValue, isGreaterThan: lastTime)
                .order(by: Post.CodingKeys.time.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Post.self)
        }
    }
    
    
    func getPostsByTimeAndId(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [Post], lastDocument: DocumentSnapshot?) {
        if let lastDocument = lastDocument {
            return try await postsCollection
                .whereField(Post.CodingKeys.ownerUid.rawValue, isEqualTo: userId)
                .order(by: Post.CodingKeys.time.rawValue, descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Post.self)
        } else {
            return try await postsCollection
                .whereField(Post.CodingKeys.ownerUid.rawValue, isEqualTo: userId)
                .order(by: Post.CodingKeys.time.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Post.self)
        }
    }
    
    func getNewPosts(highestScore: Int, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [Post], lastDocument: DocumentSnapshot?) {
        if let lastDocument = lastDocument {
            return try await postsCollection
                .whereField(Post.CodingKeys.score.rawValue, isGreaterThan: highestScore)
                .order(by: Post.CodingKeys.score.rawValue, descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Post.self)
        } else {
            return try await postsCollection
                .whereField(Post.CodingKeys.score.rawValue, isGreaterThan: highestScore)
                .order(by: Post.CodingKeys.score.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Post.self)
        }
    }
    
    func getOldPosts(lowestScore: Int, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [Post], lastDocument: DocumentSnapshot?) {
        if let lastDocument = lastDocument {
            return try await postsCollection
                .whereField(Post.CodingKeys.score.rawValue, isLessThan: lowestScore)
                .order(by: Post.CodingKeys.score.rawValue, descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Post.self)
        } else {
            return try await postsCollection
                .whereField(Post.CodingKeys.score.rawValue, isLessThan: lowestScore)
                .order(by: Post.CodingKeys.score.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Post.self)
        }
    }
    
    
    func getPostsByLikeAndId(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [Post], lastDocument: DocumentSnapshot?) {
        if let lastDocument = lastDocument {
            return try await postsCollection
                .whereField(Post.CodingKeys.ownerUid.rawValue, isEqualTo: userId)
                .order(by: Post.CodingKeys.likeNumber.rawValue, descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Post.self)
        } else {
            return try await postsCollection
                .whereField(Post.CodingKeys.ownerUid.rawValue, isEqualTo: userId)
                .order(by: Post.CodingKeys.likeNumber.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Post.self)
        }
    }
    
    func getAllPostsCount() async throws -> Int {
        try await postsCollection
            .aggregateCount()
    }
    
    
    func storyAddLike(storyId: String, ownerId: String, uid: String) async throws {
        try await storyLikeDocument(ownerId: ownerId, storyId: storyId, uid: uid).setData(["time": Timestamp(), "id": uid])
        try await storyDocument(ownerId: ownerId, storyId: storyId).updateData([Post.CodingKeys.likeNumber.rawValue : FieldValue.increment(1.0)])
    }
    
    func storyRemoveLike(storyId: String, ownerId: String, uid: String) async throws {
        try await storyLikeDocument(ownerId: ownerId, storyId: storyId, uid: uid).delete()
        try await storyDocument(ownerId: ownerId, storyId: storyId).updateData([Post.CodingKeys.likeNumber.rawValue : FieldValue.increment(-1.0)])
    }
    
    func checkStoryLike(storyId: String, ownerId: String, uid: String) async throws -> Bool {
        do{
            let doc = try await storyLikeDocument(ownerId: ownerId, storyId: storyId, uid: uid).getDocument()
            return doc.exists
        } catch {
            throw error
        }
    }
    
    
    func getStoriesByTime(count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [Story], lastDocument: DocumentSnapshot?) {
        
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -48, to: Date())!

        if let lastDocument = lastDocument {
            return try await storiesCollection
                .order(by: Story.CodingKeys.time.rawValue, descending: true)
                .whereField(Story.CodingKeys.time.rawValue, isGreaterThan: twentyFourHoursAgo)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Story.self)
        } else {
            return try await storiesCollection
                .order(by: Story.CodingKeys.time.rawValue, descending: true)
                .whereField(Story.CodingKeys.time.rawValue, isGreaterThan: twentyFourHoursAgo)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Story.self)
        }
    }
    
    
    func getUserStoriesByTime(uid: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [Story], lastDocument: DocumentSnapshot?) {
        
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -48, to: Date())!

        if let lastDocument = lastDocument {
            return try await allStoryCollection(uid: uid)
                .order(by: Story.CodingKeys.time.rawValue, descending: true)
                .whereField(Story.CodingKeys.time.rawValue, isGreaterThan: twentyFourHoursAgo)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Story.self)
        } else {
            return try await allStoryCollection(uid: uid)
                .order(by: Story.CodingKeys.time.rawValue, descending: true)
                .whereField(Story.CodingKeys.time.rawValue, isGreaterThan: twentyFourHoursAgo)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Story.self)
        }
    }
    
    func uploadStory(story: Story) async throws {
        try  lastStoryDocument(uid: story.ownerUid).setData(from: story, merge: false)
        try  storyDocument(ownerId: story.ownerUid, storyId: story.id).setData(from: story, merge: false)

    }
    
   

    func addLike(postId: String, uid: String) async throws {
        try await postLikeDocument(postId: postId, uid: uid).setData(["time": Timestamp(), "id": uid])
        try await userPostLikesDocument(postId: postId, uid: uid).setData(["time": Timestamp(), "id": postId])
        try await postDocument(postId: postId).updateData([Post.CodingKeys.likeNumber.rawValue : FieldValue.increment(1.0)])

    }
    
    
    func addSeen(postId: String, uid: String) async throws {
       
        try await postDocument(postId: postId).updateData([Post.CodingKeys.seenUserIds.rawValue : FieldValue.arrayUnion([uid])])

    }
    
    
    func updateCaption(postId: String, caption: String) async throws {
        
        try await postDocument(postId: postId).updateData([Post.CodingKeys.caption.rawValue : caption])

    }
    
    
    func removeLike(postId: String, uid: String) async throws {
        try await postLikeDocument(postId: postId, uid: uid).delete()
        try await userPostLikesDocument(postId: postId, uid: uid).delete()
        try await postDocument(postId: postId).updateData([Post.CodingKeys.likeNumber.rawValue : FieldValue.increment(-1.0)])

    }
    
    func checkPostLike(postId: String, uid: String) async throws -> Bool {
        do{
            let doc = try await postLikeDocument(postId: postId, uid: uid).getDocument()
            return doc.exists
        } catch {
            throw error
        }
    }
    
  
    func addComment(postId: String, comment: Comment) async throws {
        
        try  postCommentDocument(postId: postId, commentId: comment.id).setData(from: comment, merge: false)
        try await postDocument(postId: postId).updateData([Post.CodingKeys.commentNumber.rawValue : FieldValue.increment(1.0)])

    }
    
    
    func replyToComment(postId: String, commentId: String, comment: Comment) async throws {
        
        try  postCommentRepliesDocument(postId: postId, ReplyId: comment.id, commentId: commentId).setData(from: comment, merge: false)
        try await postDocument(postId: postId).updateData([Post.CodingKeys.commentNumber.rawValue : FieldValue.increment(1.0)])
        try await postCommentDocument(postId: postId, commentId: commentId).updateData([Comment.CodingKeys.replyNumber.rawValue : FieldValue.increment(1.0)])
    }
    
    func getReplies(postId: String, commentId: String , count: Int = 5, lastDocument: DocumentSnapshot?) async throws -> (output: [Comment] , lastDocument: DocumentSnapshot?){
        
        if let lastDocument = lastDocument {
            try await postCommentRepliesCollection(postId: postId, commentId: commentId)
                .order(by: Comment.CodingKeys.time.rawValue, descending: false)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Comment.self)
        } else {
            try await postCommentRepliesCollection(postId: postId, commentId: commentId)
                .order(by: Comment.CodingKeys.time.rawValue, descending: false)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Comment.self)
        }
            
    }
    
    
    func likeComment(postId: String, commentId: String, uid: String) async throws {
        
        try  await postCommentLikesDocument(postId: postId, uid: uid, commentId: commentId).setData(["time": Timestamp(), "uid": uid])
        try await postCommentDocument(postId: postId, commentId: commentId).updateData([Comment.CodingKeys.likeNumber.rawValue : FieldValue.increment(1.0)])
    }
    
    func unlikeComment(postId: String, commentId: String, uid: String) async throws {
        
        try  await postCommentLikesDocument(postId: postId, uid: uid, commentId: commentId).delete()
        try await postCommentDocument(postId: postId, commentId: commentId).updateData([Comment.CodingKeys.likeNumber.rawValue : FieldValue.increment(-1.0)])
    }
    
    func checkCommentLike(postId: String, commentId: String, uid: String) async throws -> Bool {
        do{
            let doc = try  await postCommentLikesDocument(postId: postId, uid: uid, commentId: commentId).getDocument()
            return doc.exists
        } catch {
            throw error
        }
    }
    
    func likeReply(postId: String, commentId: String, replyId: String, uid: String) async throws{
        try await postCommentReplyLikeDocument(postId: postId, ReplyId: replyId, commentId: commentId, uid: uid).setData(["time": Timestamp(), "uid": uid])
        try await postCommentRepliesDocument(postId: postId, ReplyId: replyId, commentId: commentId).updateData([Comment.CodingKeys.likeNumber.rawValue : FieldValue.increment(1.0)])
    }
    
    func unlikeReply(postId: String, commentId: String, replyId: String, uid: String) async throws{
        try await postCommentReplyLikeDocument(postId: postId, ReplyId: replyId, commentId: commentId, uid: uid).delete()
        try await postCommentRepliesDocument(postId: postId, ReplyId: replyId, commentId: commentId).updateData([Comment.CodingKeys.likeNumber.rawValue : FieldValue.increment(-1.0)])
    }
    
    func checkReplyLike(postId: String, commentId: String, replyId: String, uid: String) async throws -> Bool {
        do{
            let doc = try  await postCommentReplyLikeDocument(postId: postId, ReplyId: replyId, commentId: commentId, uid: uid).getDocument()
            return doc.exists
        } catch {
            throw error
        }
    }
    
    func removeReply(postId: String, commentId: String, replyId: String) async throws{
        //try await postCommentReplyLikeDocument(postId: postId, ReplyId: replyId, commentId: commentId, uid: uid).delete()
        try await postCommentRepliesDocument(postId: postId, ReplyId: replyId, commentId: commentId).delete()
        try await postCommentDocument(postId: postId, commentId: commentId).updateData([Comment.CodingKeys.replyNumber.rawValue : FieldValue.increment(-1.0)])

    }
    
    func removeComment(postId: String, commentId: String) async throws{
        try await postCommentDocument(postId: postId, commentId: commentId).delete()
        try await postDocument(postId: postId).updateData([Post.CodingKeys.commentNumber.rawValue : FieldValue.increment(-1.0)])
    }
    
    
    func getComments(postId: String , count: Int = 5, lastDocument: DocumentSnapshot?)  async throws -> (output: [Comment] , lastDocument: DocumentSnapshot?){
        
        if let lastDocument = lastDocument {
            
            try await postCommentCollection(postId: postId)
                .order(by: Post.CodingKeys.time.rawValue, descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Comment.self)
        } else {
            try await postCommentCollection(postId: postId)
                .order(by: Post.CodingKeys.time.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Comment.self)
        }
   
    }
    
    func editComment(postId: String, commentId: String, content: String) async throws{
        try await postCommentDocument(postId: postId, commentId: commentId).updateData([Comment.CodingKeys.content.rawValue : content ])
    }
    
    func editReply(postId: String, commentId: String, replyId: String, content: String) async throws{
        try await postCommentRepliesDocument(postId: postId, ReplyId: replyId, commentId: commentId).updateData([Comment.CodingKeys.content.rawValue : content ])
    }
    
    func getcomment(postId: String, commentId: String) async throws -> Comment {
        return try await postCommentDocument(postId: postId, commentId: commentId).getDocument(as: Comment.self)
    }
    
    func getReply(postId: String, commentId: String, replyId: String) async throws -> Comment {
        return try await postCommentRepliesDocument(postId: postId, ReplyId: replyId, commentId: commentId).getDocument(as: Comment.self)
    }
    
    
    func getLikersIdByTime(postId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [String], lastDocument: DocumentSnapshot?) {
        let query: Query
        
        if let lastDocument = lastDocument {
            query = postLikeCollection(postId: postId)
                .order(by: "time", descending: false)
                .start(afterDocument: lastDocument)
                .limit(to: count)
        } else {
            query = postLikeCollection(postId: postId)
                .order(by: "time", descending: false)
                .limit(to: count)
        }
        
        let snapshot = try await query.getDocuments()
        
        let likersIds = snapshot.documents.compactMap { document in
            return document.get("id") as? String
        }
        
        return (likersIds, snapshot.documents.last)
    }
    
    func getCommentLikersIdByTime(postId: String, commentId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [String], lastDocument: DocumentSnapshot?) {
        let query: Query
        
        if let lastDocument = lastDocument {
            query = postCommentLikesCollection(postId: postId, commentId: commentId)
                .order(by: "time", descending: false)
                .start(afterDocument: lastDocument)
                .limit(to: count)
        } else {
            query = postCommentLikesCollection(postId: postId, commentId: commentId)
                .order(by: "time", descending: false)
                .limit(to: count)
        }
        
        let snapshot = try await query.getDocuments()
        
        let likersIds = snapshot.documents.compactMap { document in
            return document.get("uid") as? String
        }
        
        return (likersIds, snapshot.documents.last)
    }
    
    
    func getReplyLikersIdByTime(postId: String, commentId: String, replyId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [String], lastDocument: DocumentSnapshot?) {
        let query: Query
        
        if let lastDocument = lastDocument {
            query = postCommentReplyLikeCollection(postId: postId, ReplyId: replyId, commentId: commentId)
                .order(by: "time", descending: false)
                .start(afterDocument: lastDocument)
                .limit(to: count)
        } else {
            query = postCommentReplyLikeCollection(postId: postId, ReplyId: replyId, commentId: commentId)
                .order(by: "time", descending: false)
                .limit(to: count)
        }
        
        let snapshot = try await query.getDocuments()
        
        let likersIds = snapshot.documents.compactMap { document in
            return document.get("uid") as? String
        }
        
        return (likersIds, snapshot.documents.last)
    }
    
    
    
    func updateReportNumber(postId: String) async throws{
        try await postDocument(postId: postId).updateData([Post.CodingKeys.reportNumber.rawValue : FieldValue.increment(1.0)])
    }
    
    func deletePost( postId: String) async throws {
        try await postDocument(postId: postId).delete()
    }

}
