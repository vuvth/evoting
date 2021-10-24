pragma solidity 0.6.11;

import "./Verifier.sol";

contract Voting is Verifier {
    event Vote(uint256 sessionId, uint256 voteCode, uint256 candidateId);

    struct VSession {
        uint256 root;
        string question;
        string[] candidates;
        mapping(uint256 => uint256) voteCounters;
        mapping(uint256 => bool) voteCodes;
    }

    uint256 public sessionNumber;
    mapping(uint256 => VSession) public sessions;

    constructor() public {}

    function createVoteSession(uint256 _root) public {
        sessions[sessionNumber].question = "Liv vs MU, Who win?";
        sessions[sessionNumber].root = _root;
        sessions[sessionNumber].candidates.push("Liv");
        sessions[sessionNumber].candidates.push("MU");
        sessionNumber = sessionNumber + 1;
    }

    function vote(
        uint256 _sessionId,
        uint256 _voteCode,
        uint256 _candidateId,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c
    ) public {
        require(
            _candidateId < sessions[_sessionId].candidates.length,
            "invalid-vote"
        );
        require(sessions[_sessionId].voteCodes[_voteCode] == false, "voted");
        require(
            Verifier.verifyProof(
                a,
                b,
                c,
                [sessions[_sessionId].root, _voteCode]
            ),
            "not-allowed-for-vote"
        );
        sessions[_sessionId].voteCodes[_voteCode] = true;
        sessions[_sessionId].voteCounters[_candidateId]++;

        emit Vote(_sessionId, _voteCode, _candidateId);
    }

    function reportAll(uint256 _sessionId)
        public
        view
        returns (uint256[] memory numberVotes)
    {
        uint256 candidateNumber = sessions[_sessionId].candidates.length;
        numberVotes = new uint256[](candidateNumber);

        for (uint256 i = 0; i < candidateNumber; ++i) {
            numberVotes[i] = sessions[_sessionId].voteCounters[i];
        }
    }
}