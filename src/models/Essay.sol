// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

struct Essay {
    uint8 cohort;
    uint8 week;
    uint16 voteCount; // NOTE moved to here from end for more efficient storage
    string name;
    string image;
    string description;
    string contentHash; // TODO switch to fixed-size bytes array
    string writerName;
    string writerAddress; // TODO switch to address
    string publicationURL;
    string archivalURL;
}
