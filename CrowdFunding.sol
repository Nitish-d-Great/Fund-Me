// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CrowdFunding
{
    struct Campaign
    {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        address[] donators;
        uint256[] donations;
    }

    mapping (uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    function createCampaign (address _owner, string memory _title, string memory _description, uint256 _target, uint256 _deadline) public returns (uint256)
    {
        Campaign storage campaign = campaigns[numberOfCampaigns]; // we will be making changes in the state variables - hence used storage
        require(campaign.deadline < block.timestamp, "The Deadline should be a date ahead of our current date !");
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;

        numberOfCampaigns++;
        return (numberOfCampaigns - 1);
    }

    function donateToCampaign (uint256 _id) public payable
    {
        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);
        // we are not storing the amount in the contract. Instead we are directly sending the amount to the person who needs the funding - the owner of task added. 
        (bool sent,) = payable (campaign.owner).call{value: amount}("");

        if(sent)
        {
            campaign.amountCollected += amount;
        }
    }

    function getDonators (uint256 _id) view public returns (address[] memory, uint256[] memory)
    {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory)
    {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for(uint i = 0; i<numberOfCampaigns; i++)
        {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }
        return allCampaigns;
    }

}
