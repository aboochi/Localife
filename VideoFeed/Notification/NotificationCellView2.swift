//
//  NotificationCellView2.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/7/24.
//

import SwiftUI

import SwiftUI
import Kingfisher

struct NotificationCellView: View {
    
    let notification: NotificationObject
    let screenWidth = UIScreen.main.bounds.width
    @StateObject var viewModel: NotificationCellViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    @Binding var path: NavigationPath


    
    var body: some View {
        HStack(alignment: .top) {
            userAvatar
            notificationText
            Spacer()
            thumbnailImage
        }
        .padding()
        .frame(width: screenWidth)
        .onAppear {
           
            Task {
                try await viewModel.fetchInfo()
               
            }
        }
    }
    
    private var userAvatar: some View {
        
            AvatarView(photoUrl: notification.userPhotoUrls.last, username: notification.usernames.last, size: 40)
            
                .onTapGesture {
                    
                    if let userId = notification.userIds.last {
                        let user = DBUser(uid: userId, username: "placeholder")
                            let value = NavigationValuegeneral(type: .profile, user: user)
                            path.append(value)
                        }
                }
        
    }
    
    private var notificationText: some View {
        Group {
            switch notification.category {
            case NotificationCategoryEnum.postLike.rawValue:
                textForPostLike()
            case NotificationCategoryEnum.postComment.rawValue:
                textForPostComment()
            case NotificationCategoryEnum.postReply.rawValue:
                textForPostReply()
            case NotificationCategoryEnum.commentMention.rawValue:
                textForCommentMention()
            case NotificationCategoryEnum.commentLike.rawValue:
                textForCommentLike()
            case NotificationCategoryEnum.replyLike.rawValue:
                textForReplyLike()
            case NotificationCategoryEnum.follow.rawValue:
                textForFollow()
            case NotificationCategoryEnum.listingQuestion.rawValue:
                textForListingQuestion()
            case NotificationCategoryEnum.listingInterested.rawValue:
                textForListingInterested()
            case NotificationCategoryEnum.questionReply.rawValue:
                textForQuestionReply()
            case NotificationCategoryEnum.questionLike.rawValue:
                textForQuestionLike()
            case NotificationCategoryEnum.questionReplyLike.rawValue:
                textForQuestionReplyLike()
            case NotificationCategoryEnum.questionMention.rawValue:
                textForQuestionMentionLike()


            default:
                Text("")
            }
        }
        .foregroundColor(.black)
        .font(.system(size: 14))
        .multilineTextAlignment(.leading)
    }
    
    private var thumbnailImage: some View {
        Group {
           
                if viewModel.notificationType == .aboutPost {
                    
                    if let postThumbnail = notification.postThumbnail {
                        
                        postThumbnailLink(postThumbnail: postThumbnail)
                    }
                    
                } else if viewModel.notificationType == .aboutListing {
                    listingThumbnailLink()
                }
            
        }
    }
    
    @ViewBuilder
    private func postThumbnailLink(postThumbnail: String) -> some View {
      
        if let post = viewModel.post, let user = post.user {
            
           
                KFImage(URL(string: postThumbnail))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .cornerRadius(3)
                    .clipped()
                    .onTapGesture {
                        let value = NavigationValuegeneral(type: .post, post: post)
                        path.append(value)
                    }
            
         
        }
    }
    
    private func listingThumbnailLink() -> some View {
        
     Group {
            if let thumbnail = viewModel.listing?.thumbnailUrls?.first {
                KFImage(URL(string: thumbnail))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .cornerRadius(3)
                    .clipped()
                
                  
                
                
                
            } else {
                
                if let listing = viewModel.listing{
                    
                    
                    Image(systemName: CategoryIconProvider.getSystemName(for : listing.category))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.7))
                        .cornerRadius(3)
                    
                }else{
                    Image(systemName: "tag.fill")
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.7))
                        .cornerRadius(3)
                }
            }
        }
        
     .onTapGesture {
         
         let value = NavigationValuegeneral(type: .listing, listing: viewModel.listing)
         path.append(value)
     }
        
        
    }
    
    // Helper functions for different notification texts
    private func textForPostLike() -> Text {
        if let username = notification.usernames.last {
            let count = notification.usernames.count
            return Text(username)
                .fontWeight(.semibold)
            +
                Text(count > 1 ? " and \(count - 1) others" : "") +
                Text(" liked your post")
            
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
    
    private func textForPostComment() -> Text {
        if let username = notification.usernames.last, let comment = notification.text, !comment.isEmpty {
            return Text(username)
                .fontWeight(.semibold)
            +
                Text(" commented on your post: ") +
                Text(comment)
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
    
    private func textForPostReply() -> Text {
        if let username = notification.usernames.last, let comment = notification.text, !comment.isEmpty, let postOwnerUsername = notification.parentUsername {
            return Text(username)
                .fontWeight(.semibold)
            +
                Text(" replied to your comment on \(postOwnerUsername)' post: ") +
                Text(comment)
            
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
    
    private func textForCommentMention() -> Text {
        if let username = notification.usernames.last, let comment = notification.text, !comment.isEmpty, let postOwnerUsername = notification.parentUsername {
            return Text(username)
                .fontWeight(.semibold)
            +
                Text(" mentioned you in a comment on \(postOwnerUsername)' post: ") +
                Text(comment)
            
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
    
    private func textForCommentLike() -> Text {
        if let username = notification.usernames.last, let comment = notification.text, !comment.isEmpty, let postOwnerUsername = notification.parentUsername {
            let count = notification.usernames.count
            return Text(username)
                .fontWeight(.semibold)
            +
                Text(count > 1 ? " and \(count - 1) others" : "") +
                Text(" liked your comment on \(postOwnerUsername)' post: ") +
                Text(comment)
            
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
    
    private func textForReplyLike() -> Text {
        if let username = notification.usernames.last, let comment = notification.text, !comment.isEmpty, let postOwnerUsername = notification.parentUsername {
            let count = notification.usernames.count
            return Text(username)
                .fontWeight(.semibold)
            +
                Text(count > 1 ? " and \(count - 1) others" : "") +
                Text(" liked your reply to a comment on \(postOwnerUsername)' post: ") +
                Text(comment)
            
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
    
    private func textForFollow() -> Text {
        if let username = notification.usernames.last {
            return Text(username)
                .fontWeight(.semibold)
            + Text(" started following you")
            
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
    
    private func textForListingQuestion() -> Text {
        if let username = notification.usernames.last, let comment = notification.text, !comment.isEmpty {
            return Text(username)
                .fontWeight(.semibold)
            +
                Text(" has question about your listing: ") +
                Text(comment)
            
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
    
    private func textForListingInterested() -> Text {
        if let username = notification.usernames.last {
            let count = notification.usernames.count
            return Text(username)
                .fontWeight(.semibold)
            +
                Text(count > 1 ? " and \(count - 1) others" : "") +
                Text(" is interested in your listing")
            
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
    
    private func textForQuestionReply() -> Text {
        if let username = notification.usernames.last, let reply = notification.text, !reply.isEmpty, let listingOwnerUsername = notification.parentUsername {
            return Text(username)
                .fontWeight(.semibold)
            +
                Text(" replied to your question on \(listingOwnerUsername)' listing: ") +
                Text(reply)
            
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
    
    private func textForQuestionLike() -> Text {
        if let username = notification.usernames.last, let question = notification.text, !question.isEmpty, let listingOwnerUsername = notification.parentUsername {
            return Text(username)
                .fontWeight(.semibold)
            +
                Text(" liked your question on \(listingOwnerUsername)' listing: ") +
                Text(question)
            
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
    
    private func textForQuestionReplyLike() -> Text {
        if let username = notification.usernames.last, let question = notification.text, !question.isEmpty, let listingOwnerUsername = notification.parentUsername {
            return Text(username)
                .fontWeight(.semibold)
            +
                Text(" liked your reply to a question on \(listingOwnerUsername)' listing: ") +
                Text(question)
            
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
    
    private func textForQuestionMentionLike() -> Text {
        if let username = notification.usernames.last, let question = notification.text, !question.isEmpty, let listingOwnerUsername = notification.parentUsername {
            return Text(username)
                .fontWeight(.semibold)
            +
                Text(" mentioned you in a question on \(listingOwnerUsername)' listing: ") +
                Text(question)
            
            +
            Text( "  \(TimeFormatter.shared.timeAgoFormatter(time: notification.time))")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .light))
        }
        return Text("")
    }
}
