/*
    Copyright 2020 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    SPDX-License-Identifier: Apache License, Version 2.0
*/
pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";


import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ISetToken } from "../interfaces/ISetToken.sol";


/**
 * @title SetTokenViewer
 * @author Set Protocol
 *
 * SetTokenViewer enables batch queries of SetToken state.
 *
 * UPDATE:
 * - Added getSetDetails functions
 */
contract SetTokenViewer {

    struct SetDetails {
        string name;
        string symbol;
        address manager;
        address[] modules;
        ISetToken.ModuleState[] moduleStatuses;
        ISetToken.Position[] positions;
        uint256 totalSupply;
    }

    function batchFetchManagers(ISetToken[] memory _setTokens) external view returns (address[] memory) {
        address[] memory managers = new address[](_setTokens.length);

        for (uint256 i = 0; i < _setTokens.length; i++) {
            managers[i] = _setTokens[i].manager();
        }
        return managers;
    }

    function batchFetchModuleStates(
        ISetToken[] memory _setTokens,
        address[] calldata _modules
    )
        public
        view
        returns (ISetToken.ModuleState[][] memory)
    {
        ISetToken.ModuleState[][] memory states = new ISetToken.ModuleState[][](_setTokens.length);
        for (uint256 i = 0; i < _setTokens.length; i++) {
            ISetToken.ModuleState[] memory moduleStates = new ISetToken.ModuleState[](_modules.length);
            for (uint256 j = 0; j < _modules.length; j++) {
                moduleStates[j] = _setTokens[i].moduleStates(_modules[j]);
            }
            states[i] = moduleStates;
        }
        return states;
    }

    function getSetDetails(
        ISetToken _setToken,
        address[] calldata _moduleList
    ) external view returns(SetDetails memory) {
        ISetToken[] memory _setTokens = new ISetToken[](1);
        _setTokens[0] = _setToken;
        
        return SetDetails({
            name: ERC20(address(_setToken)).name(),
            symbol: ERC20(address(_setToken)).symbol(),
            manager: _setToken.manager(),
            modules: _setToken.getModules(),
            moduleStatuses: batchFetchModuleStates(_setTokens, _moduleList)[0],
            positions: _setToken.getPositions(),
            totalSupply: _setToken.totalSupply()
        });
    }
}