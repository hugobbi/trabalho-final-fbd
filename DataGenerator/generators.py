import random

def generate_guid():
    import uuid
    return str(uuid.uuid4())

def generate_follower_guids(followed, possible_followers):
    follower_guids = []
    for follower in possible_followers:
        if random.randint(0, 1) == 1:
            if follower.guid != followed.guid:
                follower_guids.append(follower.guid)
    return follower_guids

