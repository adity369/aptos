module MyModule::CrowdfundedProjects {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a crowdfunding project.
    struct Project has store, key {
        owner: address,
        total_funds: u64,
        milestone_goal: u64,
        funds_released: u64,
    }

    /// Function to create a new environmental project.
    public fun create_project(owner: &signer, milestone_goal: u64) {
        let project = Project {
            owner: signer::address_of(owner),
            total_funds: 0,
            milestone_goal,
            funds_released: 0,
        };
        move_to(owner, project);
    }

    /// Function to fund a project and release funds based on milestone achievement.
    public fun fund_project(funder: &signer, project_owner: address, amount: u64) acquires Project {
        let project = borrow_global_mut<Project>(project_owner);
        let payment = coin::withdraw<AptosCoin>(funder, amount);
        coin::deposit<AptosCoin>(project_owner, payment);

        project.total_funds = project.total_funds + amount;

        // Automatically release funds if milestone is met
        if (project.total_funds >= project.milestone_goal && project.funds_released == 0) {
            project.funds_released = project.milestone_goal;
            // Logic to release funds to the owner can go here
        }
    }
}
