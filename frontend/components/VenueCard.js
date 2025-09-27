import React, { useState } from 'react';
import { View, Text, Image, TouchableOpacity, StyleSheet, ScrollView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

export default function VenueCard({ venue }) {
    const [showAllComments, setShowAllComments] = useState(false);
    const [liked, setLiked] = useState(false);

    const displayedReviews = showAllComments ? venue.reviews : venue.reviews.slice(0, 2);

    const renderStars = (rating) => {
        return Array.from({ length: 5 }, (_, i) => (
            <Ionicons
                key={i}
                name={i < rating ? 'star' : 'star-outline'}
                size={14}
                color="#ff6b6b"
            />
        ));
    };

    return (
        <View style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <View style={styles.venueInfo}>
                    <Image source={{ uri: venue.avatar }} style={styles.avatar} />
                    <View>
                        <Text style={styles.venueName}>{venue.name}</Text>
                        <Text style={styles.location}>{venue.location}</Text>
                    </View>
                </View>
                <TouchableOpacity>
                    <Ionicons name="ellipsis-horizontal" size={20} color="#ccc" />
                </TouchableOpacity>
            </View>

            {/* Main Image */}
            <Image source={{ uri: venue.image }} style={styles.mainImage} />

            {/* Action Bar */}
            <View style={styles.actionBar}>
                <View style={styles.leftActions}>
                    <TouchableOpacity onPress={() => setLiked(!liked)} style={styles.actionButton}>
                        <Ionicons
                            name={liked ? 'heart' : 'heart-outline'}
                            size={24}
                            color={liked ? '#ff6b6b' : '#fff'}
                        />
                    </TouchableOpacity>
                    <TouchableOpacity style={styles.actionButton}>
                        <Ionicons name="chatbubble-outline" size={22} color="#fff" />
                    </TouchableOpacity>
                    <TouchableOpacity style={styles.actionButton}>
                        <Ionicons name="paper-plane-outline" size={22} color="#fff" />
                    </TouchableOpacity>
                </View>
                <TouchableOpacity>
                    <Ionicons name="bookmark-outline" size={22} color="#fff" />
                </TouchableOpacity>
            </View>

            {/* Likes and Rating */}
            <View style={styles.statsSection}>
                <Text style={styles.likes}>{venue.likes} likes</Text>
                <View style={styles.ratingContainer}>
                    {renderStars(venue.rating)}
                    <Text style={styles.ratingText}>{venue.rating}/5</Text>
                </View>
            </View>

            {/* Description */}
            <View style={styles.descriptionSection}>
                <Text style={styles.description}>
                    <Text style={styles.venueBold}>{venue.name}</Text> {venue.description}
                </Text>
            </View>

            {/* Reviews Section */}
            <View style={styles.reviewsSection}>
                {displayedReviews.map((review, index) => (
                    <View key={index} style={styles.reviewItem}>
                        <Text style={styles.reviewText}>
                            <Text style={styles.reviewUser}>{review.user}</Text> {review.comment}
                        </Text>
                        <View style={styles.reviewMeta}>
                            {renderStars(review.rating)}
                            <Text style={styles.reviewTime}>{review.timeAgo}</Text>
                        </View>
                    </View>
                ))}

                {venue.reviews.length > 2 && !showAllComments && (
                    <TouchableOpacity onPress={() => setShowAllComments(true)}>
                        <Text style={styles.viewAllComments}>
                            View all {venue.reviews.length} reviews
                        </Text>
                    </TouchableOpacity>
                )}

                <Text style={styles.timestamp}>{venue.timeAgo}</Text>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        backgroundColor: '#000',
        marginBottom: 20,
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: 12,
    },
    venueInfo: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    avatar: {
        width: 32,
        height: 32,
        borderRadius: 16,
        marginRight: 12,
    },
    venueName: {
        color: '#fff',
        fontWeight: 'bold',
        fontSize: 14,
    },
    location: {
        color: '#aaa',
        fontSize: 12,
    },
    mainImage: {
        width: '100%',
        height: 300,
    },
    actionBar: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingHorizontal: 12,
        paddingVertical: 8,
    },
    leftActions: {
        flexDirection: 'row',
    },
    actionButton: {
        marginRight: 16,
    },
    statsSection: {
        paddingHorizontal: 12,
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 8,
    },
    likes: {
        color: '#fff',
        fontWeight: 'bold',
        fontSize: 14,
    },
    ratingContainer: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    ratingText: {
        color: '#fff',
        marginLeft: 6,
        fontSize: 12,
    },
    descriptionSection: {
        paddingHorizontal: 12,
        marginBottom: 8,
    },
    description: {
        color: '#fff',
        lineHeight: 18,
    },
    venueBold: {
        fontWeight: 'bold',
    },
    reviewsSection: {
        paddingHorizontal: 12,
        paddingBottom: 12,
    },
    reviewItem: {
        marginBottom: 8,
    },
    reviewText: {
        color: '#fff',
        lineHeight: 18,
        marginBottom: 4,
    },
    reviewUser: {
        fontWeight: 'bold',
    },
    reviewMeta: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
    },
    reviewTime: {
        color: '#aaa',
        fontSize: 12,
    },
    viewAllComments: {
        color: '#666',
        fontSize: 14,
        marginVertical: 4,
    },
    timestamp: {
        color: '#666',
        fontSize: 12,
        marginTop: 8,
    },
});