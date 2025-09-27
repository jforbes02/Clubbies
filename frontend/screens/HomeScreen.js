import React from 'react';
import { View, Text, StyleSheet, FlatList, SafeAreaView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import VenueCard from '../components/VenueCard';

const mockVenues = [
    {
        id: '1',
        name: 'Club Neon',
        location: 'Downtown District',
        avatar: 'https://picsum.photos/50/50?random=1',
        image: 'https://picsum.photos/400/300?random=1',
        likes: 342,
        rating: 4,
        description: 'The hottest club in the city with amazing DJs and incredible atmosphere! 🎵',
        timeAgo: '2 hours ago',
        reviews: [
            {
                user: 'sarah_nightlife',
                comment: 'Amazing night! The music was incredible and the vibe was perfect 🔥',
                rating: 5,
                timeAgo: '1h'
            },
            {
                user: 'mike_party',
                comment: 'Great place but a bit crowded. Still had a blast!',
                rating: 4,
                timeAgo: '45m'
            },
            {
                user: 'party_queen',
                comment: 'Best club in the city hands down! Will definitely be back',
                rating: 5,
                timeAgo: '30m'
            }
        ]
    },
    {
        id: '2',
        name: 'Rooftop Lounge',
        location: 'Upper East',
        avatar: 'https://picsum.photos/50/50?random=2',
        image: 'https://picsum.photos/400/300?random=2',
        likes: 189,
        rating: 5,
        description: 'Stunning city views with craft cocktails and chill vibes ✨',
        timeAgo: '4 hours ago',
        reviews: [
            {
                user: 'cocktail_lover',
                comment: 'The view is breathtaking and cocktails are top notch!',
                rating: 5,
                timeAgo: '2h'
            },
            {
                user: 'city_explorer',
                comment: 'Perfect spot for a date night. Romantic and classy',
                rating: 4,
                timeAgo: '1h'
            }
        ]
    },
    {
        id: '3',
        name: 'Electric Underground',
        location: 'Warehouse District',
        avatar: 'https://picsum.photos/50/50?random=3',
        image: 'https://picsum.photos/400/300?random=3',
        likes: 567,
        rating: 4,
        description: 'Underground techno paradise. Raw energy, incredible sound system 🎧',
        timeAgo: '6 hours ago',
        reviews: [
            {
                user: 'techno_head',
                comment: 'This place is INSANE! Best sound system in the city',
                rating: 5,
                timeAgo: '3h'
            },
            {
                user: 'rave_girl',
                comment: 'Lost myself in the music all night. Pure magic!',
                rating: 5,
                timeAgo: '2h'
            },
            {
                user: 'bass_lover',
                comment: 'The bass hits different here. Mind-blowing experience',
                rating: 4,
                timeAgo: '1h'
            }
        ]
    }
];

export default function HomeScreen() {
    const renderHeader = () => (
        <View style={styles.header}>
            <Text style={styles.logo}>Clubbies</Text>
            <View style={styles.headerIcons}>
                <Ionicons name="heart-outline" size={24} color="#fff" style={styles.headerIcon} />
                <Ionicons name="paper-plane-outline" size={24} color="#fff" />
            </View>
        </View>
    );

    const renderVenue = ({ item }) => <VenueCard venue={item} />;

    return (
        <SafeAreaView style={styles.container}>
            {renderHeader()}
            <FlatList
                data={mockVenues}
                renderItem={renderVenue}
                keyExtractor={(item) => item.id}
                showsVerticalScrollIndicator={false}
                style={styles.feed}
            />
        </SafeAreaView>
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
        paddingHorizontal: 16,
        paddingVertical: 12,
        borderBottomWidth: 0.5,
        borderBottomColor: '#333',
    },
    logo: {
        fontSize: 24,
        fontWeight: 'bold',
        color: '#ff6b6b',
    },
    headerIcons: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    headerIcon: {
        marginRight: 16,
    },
    feed: {
        flex: 1,
    },
});