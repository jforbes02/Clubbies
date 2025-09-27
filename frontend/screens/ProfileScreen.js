import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity, ScrollView } from 'react-native';

const mockClubs = [
    {
        id: '1',
        name: 'The Underground',
        image: 'https://images.unsplash.com/photo-1571266028243-4e85ca450fb6?w=200&h=200&fit=crop',
        rating: 4.8,
        genre: 'Electronic',
    },
    {
        id: '2',
        name: 'Neon Nights',
        image: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=200&h=200&fit=crop',
        rating: 4.6,
        genre: 'Hip Hop',
    },
    {
        id: '3',
        name: 'Velvet Lounge',
        image: 'https://images.unsplash.com/photo-1504196606672-aef5c9cefc92?w=200&h=200&fit=crop',
        rating: 4.9,
        genre: 'Jazz',
    },
];

const ClubCard = ({ club }) => (
    <TouchableOpacity style={styles.clubCard}>
        <Image source={{ uri: club.image }} style={styles.clubImage} />
        <View style={styles.clubOverlay}>
            <Text style={styles.clubName}>{club.name}</Text>
            <Text style={styles.clubGenre}>{club.genre}</Text>
            <View style={styles.clubRating}>
                <Text style={styles.clubRatingText}>⭐ {club.rating}</Text>
            </View>
        </View>
    </TouchableOpacity>
);

export default function ProfileScreen() {
    return (
        <ScrollView style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <Text style={styles.headerTitle}>CLUBBIES</Text>
                <TouchableOpacity style={styles.headerButton}>
                    <Text style={styles.headerButtonText}>⚙</Text>
                </TouchableOpacity>
            </View>

            {/* Profile Image */}
            <View style={styles.profileImageContainer}>
                <Image
                    source={{ uri: 'https://images.unsplash.com/photo-1494790108755-2616b612b789?w=150&h=150&fit=crop&crop=face' }}
                    style={styles.profileImage}
                />
            </View>

            {/* Profile Info */}
            <View style={styles.profileInfo}>
                <Text style={styles.name}>Caroline Steele</Text>
                <Text style={styles.subtitle}>Photographer and Artist</Text>
                <Text style={styles.bio}>
                    Hi, my name is Carol and I love photography!{'\n'}
                    It's my greatest passion in life.
                </Text>
            </View>

            {/* Action Buttons */}
            <View style={styles.buttonContainer}>
                <TouchableOpacity style={styles.followButton}>
                    <Text style={styles.followButtonText}>FOLLOW</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.messageButton}>
                    <Text style={styles.messageButtonText}>MESSAGE</Text>
                </TouchableOpacity>
            </View>

            {/* Stats */}
            <View style={styles.statsContainer}>
                <View style={styles.statItem}>
                    <Text style={styles.statNumber}>15K</Text>
                    <Text style={styles.statLabel}>FOLLOWERS</Text>
                </View>
                <View style={styles.statDivider} />
                <View style={styles.statItem}>
                    <Text style={styles.statNumber}>23K</Text>
                    <Text style={styles.statLabel}>FOLLOWING</Text>
                </View>
            </View>

            {/* My Works Section */}
            <View style={styles.worksSection}>
                <View style={styles.worksSectionHeader}>
                    <Text style={styles.worksTitle}>Fav Clubs</Text>
                    <TouchableOpacity>
                        <Text style={styles.viewAllText}>View all</Text>
                    </TouchableOpacity>
                </View>

                <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.worksScrollView}>
                    {mockClubs.map((club) => (
                        <ClubCard key={club.id} club={club} />
                    ))}
                </ScrollView>
            </View>

            {/* Social Media */}
            <View style={styles.socialSection}>
                <Text style={styles.socialTitle}>Social media</Text>
                <View style={styles.socialLinks}>
                    <View style={styles.socialRow}>
                        <Text style={styles.socialIcon}>📷</Text>
                        <Text style={styles.socialHandle}>@CarolArt</Text>
                    </View>
                    <View style={styles.socialRow}>
                        <Text style={styles.socialIcon}>🐦</Text>
                        <Text style={styles.socialHandle}>@CarolArt</Text>
                    </View>
                    <View style={styles.socialRow}>
                        <Text style={styles.socialIcon}>👤</Text>
                        <Text style={styles.socialHandle}>/CarolSteele</Text>
                    </View>
                    <View style={styles.socialRow}>
                        <Text style={styles.socialIcon}>🌐</Text>
                        <Text style={styles.socialHandle}>@SteeleCarol</Text>
                    </View>
                </View>
            </View>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#000',
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingHorizontal: 20,
        paddingTop: 60,
        paddingBottom: 20,
    },
    headerButton: {
        padding: 10,
    },
    headerButtonText: {
        color: '#aaa',
        fontSize: 20,
    },
    headerTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#ff6b6b',
        letterSpacing: 2,
    },
    profileImageContainer: {
        alignItems: 'center',
        marginBottom: 20,
    },
    profileImage: {
        width: 120,
        height: 120,
        borderRadius: 60,
        borderWidth: 3,
        borderColor: '#ff6b6b',
    },
    profileInfo: {
        alignItems: 'center',
        paddingHorizontal: 20,
        marginBottom: 30,
    },
    name: {
        fontSize: 28,
        fontWeight: 'bold',
        color: '#ff6b6b',
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 16,
        color: '#aaa',
        marginBottom: 16,
    },
    bio: {
        fontSize: 16,
        color: '#aaa',
        textAlign: 'center',
        lineHeight: 24,
    },
    buttonContainer: {
        flexDirection: 'row',
        justifyContent: 'center',
        paddingHorizontal: 20,
        marginBottom: 30,
        gap: 15,
    },
    followButton: {
        backgroundColor: '#ff6b6b',
        paddingVertical: 12,
        paddingHorizontal: 30,
        borderRadius: 25,
        minWidth: 120,
    },
    followButtonText: {
        color: '#000',
        fontWeight: 'bold',
        textAlign: 'center',
        fontSize: 16,
    },
    messageButton: {
        backgroundColor: 'transparent',
        borderWidth: 2,
        borderColor: '#ff6b6b',
        paddingVertical: 10,
        paddingHorizontal: 30,
        borderRadius: 25,
        minWidth: 120,
    },
    messageButtonText: {
        color: '#ff6b6b',
        fontWeight: 'bold',
        textAlign: 'center',
        fontSize: 16,
    },
    statsContainer: {
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        paddingHorizontal: 20,
        marginBottom: 30,
    },
    statItem: {
        alignItems: 'center',
        flex: 1,
    },
    statNumber: {
        fontSize: 24,
        fontWeight: 'bold',
        color: '#fff',
        marginBottom: 4,
    },
    statLabel: {
        fontSize: 12,
        color: '#aaa',
        letterSpacing: 1,
    },
    statDivider: {
        width: 1,
        height: 40,
        backgroundColor: '#333',
        marginHorizontal: 20,
    },
    worksSection: {
        marginBottom: 30,
    },
    worksSectionHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingHorizontal: 20,
        marginBottom: 15,
    },
    worksTitle: {
        fontSize: 20,
        fontWeight: 'bold',
        color: '#ff6b6b',
    },
    viewAllText: {
        fontSize: 16,
        color: '#aaa',
    },
    worksScrollView: {
        paddingLeft: 20,
    },
    clubCard: {
        marginRight: 15,
        borderRadius: 15,
        overflow: 'hidden',
        width: 160,
        height: 120,
    },
    clubImage: {
        width: '100%',
        height: '100%',
        resizeMode: 'cover',
    },
    clubOverlay: {
        position: 'absolute',
        bottom: 0,
        left: 0,
        right: 0,
        backgroundColor: 'rgba(0,0,0,0.8)',
        padding: 12,
    },
    clubName: {
        color: '#fff',
        fontSize: 16,
        fontWeight: 'bold',
        marginBottom: 2,
    },
    clubGenre: {
        color: '#ff6b6b',
        fontSize: 12,
        marginBottom: 4,
    },
    clubRating: {
        alignSelf: 'flex-start',
    },
    clubRatingText: {
        color: '#fff',
        fontSize: 12,
        fontWeight: '500',
    },
    socialSection: {
        paddingHorizontal: 20,
        marginBottom: 30,
    },
    socialTitle: {
        fontSize: 20,
        fontWeight: 'bold',
        color: '#ff6b6b',
        marginBottom: 15,
    },
    socialLinks: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: 15,
    },
    socialRow: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: '#111',
        paddingVertical: 10,
        paddingHorizontal: 15,
        borderRadius: 20,
        minWidth: '45%',
    },
    socialIcon: {
        fontSize: 16,
        marginRight: 8,
    },
    socialHandle: {
        color: '#aaa',
        fontSize: 16,
    },
});